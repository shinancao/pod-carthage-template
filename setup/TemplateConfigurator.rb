require 'fileutils'
require 'colored2'

module Project

	class TemplateConfigurator 

		attr_reader :project_name


		def initialize(project_name)
			@project_name = project_name
			@message_bank = MessageBank.new(self)
		end
		
		def ask_with_answers(question, possible_answers)
			
			print "\n#{question}? ["

			print_info = Proc.new {

				possible_answers_string = possible_answers.each_with_index do |answer, i|
					_answer = (i == 0) ? answer.underlined : answer
					print " " + _answer
					print(" /") if i != possible_answers.length-1
				end
				print " ]\n" 
			}
			print_info.call

			answer = ""

			loop do
				@message_bank.show_prompt
				#从屏幕上获得用户输入
				answer = gets.downcase.chomp 

				answer = "yes" if answer == "y"
				answer = "no" if answer == "n"

				#default to first answer
				if answer == ""
					answer = possible_answers[0].downcase
					print answer.yellow
				end 

				break if possible_answers.map { |a| a.downcase }.include? answer

				print "\nPossible answers are ["
				print_info.call
			end

			answer
		end

		def run

			reinitialize_git_repo

			@message_bank.welcome_message

			framework = self.ask_with_answers("What language do you want to use", ["Swift", "ObjC"]).to_sym
			xcodeproj_path = ""
			case framework
				when :swift
					xcodeproj_path = "templates/swift/PROJECT/PROJECT.xcodeproj"

				when :objc
					xcodeproj_path = "templates/ios/PROJECT/PROJECT.xcodeproj"
			end

			Project::ProjectManipulator.new({
						:configurator => self,
						:xcodeproj_path => xcodeproj_path,
						:platform => :ios
						}).run

			move_project_dir framework
			replace_variables_in_files
			rename_template_files
			move_template_files

			clean_template_files

			Project::DependencyConfigurator.new({
				:configurator => self,
				:xcodeproj_path => project_folder + "/#{project_name}.xcodeproj"
				}).run
			
		end

		def reinitialize_git_repo
			`rm -rf .git`
			`git init`
		end

		def move_project_dir framework
			src = ""
			case framework
			when :swift
				src = "templates/swift/" + @project_name

			when :objc
				src = "templates/ios/" + @project_name
			end

			dest = File.dirname(File.dirname(File.expand_path(__FILE__)))
		
			FileUtils.mv "#{src}", "#{dest}"
		end

		def rename_template_files
			FileUtils.mv "PROJECT_README.md", "README.md"
			FileUtils.mv "PROJECT_LICENSE", "LICENSE"
			FileUtils.mv "NAME.podspec", "#{project_name}.podspec"
		end

		def move_template_files
			FileUtils.mv "README.md", project_folder
			FileUtils.mv "LICENSE", project_folder
			FileUtils.mv "#{project_name}.podspec", project_folder
			FileUtils.mv ".gitignore", project_folder
			FileUtils.mv ".git", project_folder
		end

		def clean_template_files
			["templates", "setup", "configure.rb"].each do |asset|
				`rm -rf #{asset}`
			end
		end

		def replace_variables_in_files
			file_names = ['PROJECT_LICENSE', 'PROJECT_README.md', 'NAME.podspec']
			file_names.each do |file_name|
				text = File.read(file_name)
				text.gsub!("${PROJECT_NAME}", @project_name)
				text.gsub!("${REPO_NAME}", @project_name.gsub('+', '-'))
				text.gsub!("${USER_NAME}", user_name)
				text.gsub!("${USER_EMAIL}", user_email)
				text.gsub!("${YEAR}", year)
				text.gsub!("${DATE}", date)
				File.open(file_name, "w") { |file| file.puts text }
			end
		end

		def validate_user_details
			return (user_email.length > 0) && (user_name.length > 0)
		end

		def project_folder
			return File.dirname(File.dirname(File.expand_path(__FILE__))) + "/#{project_name}"
		end

		#----------------------------------------#

		def user_name
			(ENV['GIT_COMMITTER_NAME'] || github_user_name || `git config user.name` || `<GITHUB_USERNAME>` ).strip
		end

		def github_user_name
      		github_user_name = `security find-internet-password -s github.com | grep acct | sed 's/"acct"<blob>="//g' | sed 's/"//g'`.strip
      		is_valid = github_user_name.empty? or github_user_name.include? '@'
      		return is_valid ? nil : github_user_name
    	end

    	def user_email
      		(ENV['GIT_COMMITTER_EMAIL'] || `git config user.email`).strip
    	end

		def year
			Time.now.year.to_s
		end

		def date
			Time.now.strftime "%m/%d/%Y"
		end

		#----------------------------------------#
	end
	
end