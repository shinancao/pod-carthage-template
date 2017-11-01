require 'xcodeproj'

module Project

	class DependencyConfigurator
		def initialize(options)
			@xcodeproj_path = options.fetch(:xcodeproj_path)
			@configurator = options.fetch(:configurator)
		end

		def run
			if run_carthage_if_exist
				@project = Xcodeproj::Project.open(@xcodeproj_path)
				add_frameworks
				add_run_script
				@project.save

				create_workspace
				setup_pod_dependency
			end
		end

		def run_carthage_if_exist
			if File.exist?("Cartfile")
				text = File.read("Cartfile")
				if text.length > 0

					FileUtils.mv "Cartfile", project_folder

					Dir.chdir(project_folder) do
						3.times do |i|
							time = (i==0)? "time" : "times"
							puts "Attempt to run carthage update for #{i + 1} #{time}."
							puts ""
							if system "carthage update --use-submodules --platform iOS"
								return true
							end
						end
					end
				end
			end

			return false
		end

		def add_frameworks
			
			target = @project.targets.first
			group = @project.main_group.find_subpath(File.join("Frameworks"), true)
			group.set_source_tree('SOURCE_ROOT')
			build_ref = target.frameworks_build_phase

			framework_path = project_folder + "/Carthage/Build/iOS/"
			
			Dir.glob(framework_path + "*.framework").each do |path| 
				file_ref = group.new_reference(path)
				build_ref.add_file_reference(file_ref)
			end
		end

		def add_run_script
			target = @project.targets.first
			phase = target.new_shell_script_build_phase
			phase.shell_script = "/usr/local/bin/carthage copy-frameworks"
			
			Dir.chdir(project_folder) do
				phase.input_paths = Dir.glob("Carthage/Build/iOS/" + "*.framework").map { |file| "$(SRCROOT)/" + file }
			end
		end

		def create_workspace 
			
			Dir.chdir(project_folder) do
				file_ref = Xcodeproj::Workspace::FileReference.new(@configurator.project_name + ".xcodeproj")
				workspace = Xcodeproj::Workspace.new(nil, file_ref)

				Dir.glob("Carthage/Checkouts/*/*.xcodeproj") do |file|
					workspace << file
				end

				workspace.save_as(@configurator.project_name + ".xcworkspace")
			end
		end

		def setup_pod_dependency
			dependencys = []

			file = File.open(project_folder + "/Cartfile")
			file.each_line do |line|
				if /^github/ =~ line
					/\/(.*?)\"/ =~ line 
					libname = $1
					
					unless /\"\s(.+)\n?/ =~ line
						# 为空的时候就没有指定版本号
						dependencys << "  s.dependency " + "\"#{libname}\"\n"
					else
						ver = $1
						if /(.*)\s#/ =~ ver
							#去除带注释的情况
							ver = $1
						end
						
						if /^==\s(.*)/ =~ ver
							dependencys << "  s.dependency " + "\"#{libname}\"\, " + "\"#{$1}\"\n"
						elsif /\".*\"/ =~ ver
							dependencys << "  s.dependency " + "\"#{libname}\"\, :branch => " + ver
						else
							dependencys << "  s.dependency " + "\"#{libname}\"\, " + "\"#{ver}\"\n"
						end

					end
				end
			end

			file.close

			if dependencys.length > 0
				file_name = project_folder + "/#{@configurator.project_name}.podspec"
				text = File.read(file_name)

				text.gsub!(/^\s?end\s?/, "")

				file = File.open(file_name, "w")

				file.puts text

				dependencys.each do |dependency|
					file.puts "#{dependency}"
				end

				file.puts "end"

				file.close
			end

		end

		def project_folder
			File.dirname @xcodeproj_path
		end


	end
end