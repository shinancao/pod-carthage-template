require 'xcodeproj'

module Project

	class ProjectManipulator
		attr_reader :configurator, :xcodeproj_path, :platform, :string_replacements

		def self.perform(options)
      		new(options).perform
    	end

		def initialize(options)
			@xcodeproj_path = options.fetch(:xcodeproj_path)
			@configurator = options.fetch(:configurator)
			@platform = options.fetch(:platform)
		end

		def run

			@project = Xcodeproj::Project.open(@xcodeproj_path)
			rename_PROJECT_h
			rename_targets
			@project.save

			@string_replacements = {
				"PROJECT_OWNER" => @configurator.user_name,
				"TODAYS_DATE" => @configurator.date,
				"TODAYS_YEAR" => @configurator.year,
				"PROJECT" => @configurator.project_name 
			}

			replace_internal_project_settings

			rename_files
			rename_project_folder
		end

		def project_folder
			File.dirname @xcodeproj_path
		end

		def rename_project_folder
			if Dir.exist? project_folder
				File.rename(project_folder, File.dirname(project_folder) + "/" + @configurator.project_name)
			end
		end

		def rename_files
			# shared schemes have project specific names
			scheme_path = project_folder + "/PROJECT.xcodeproj/xcshareddata/xcschemes/"
			File.rename(scheme_path + "PROJECT.xcscheme", scheme_path + @configurator.project_name + ".xcscheme")

			# rename xcproject
			File.rename(project_folder + "/PROJECT.xcodeproj", project_folder + "/" + @configurator.project_name + ".xcodeproj")
		end

		def rename_PROJECT_h
			# remove PROJECT.h reference
			target = @project.targets.first
			file_ref = target.headers_build_phase.files_references.find {|ref| ref.path.to_s.end_with?("PROJECT.h")}
			target.headers_build_phase.remove_file_reference(file_ref) 
			# remove frome group
			group = @project.main_group.find_subpath(File.join("Sources"), true)
			p group.files
			file_ref = group.files.find { |ref| ref.path.to_s.end_with?("PROJECT.h")}
			file_ref.remove_from_project

			# rename PROJECT.h to {project_name}.h
			h_file = @configurator.project_name + ".h"
			File.rename(project_folder + "/Sources/PROJECT.h", project_folder + "/Sources/" + h_file)

			# add new {project_name}.h reference 
			file_ref = group.new_reference(h_file)
			target.add_file_references([file_ref])

			# set the head file public 
			build_file = target.headers_build_phase.files.find {|file| file.display_name == h_file }
			build_file.settings = { "ATTRIBUTES" => ["Public"] }
		end

		def rename_targets
			project_target = @project.native_targets.find { |target| target.name == "PROJECT" }
			demo_target = @project.native_targets.find { |target| target.name == "PROJECTDemo" }
			project_target.name = @configurator.project_name
			demo_target.name = @configurator.project_name + "Demo"
		end

		def replace_internal_project_settings
			Dir.glob(project_folder + "/**/**").each do |name|

				next if Dir.exist? name
				text = File.read(name)

				for find, replace in @string_replacements
					text = text.gsub(find, replace)
				end

				File.open(name, "w") { |file| file.puts text }
			end
		end
	end
	
end