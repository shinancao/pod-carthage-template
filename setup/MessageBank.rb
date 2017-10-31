module Project
	class MessageBank
		attr_reader :configurator

		def initialize(config)
			@configurator = config
			
		end

		def show_prompt
			print " > ".green
		end

		def yellow_bang
			"! ".yellow
		end

		def green_bang
			"! ".green
		end

		def red_bang
			"! ".red
		end

		def run_command command, output_command=nil
			output_command ||= command

			puts " " + output_command.magenta
			system command
		end

		def welcome_message
			unless @configurator.validate_user_details
				run_setup_questions
			end
		end

		def run_setup_questions
			puts yellow_bang + "Before you can create a new library we need to setup your git credentials."
			puts "user.name" + @configurator.user_name
			unless  @configurator.user_name.length > 0
				puts "\n What is your name? "
				answer = ""
				loop do 
					show_prompt
					answer = gets.chomp
					break if answer.length > 0

					puts red_bang + "Please enter a name."
				end

				puts ""
				puts green_bang + "Setting your name in git to " + answer
				run_command('git config user.name "' + answer + '"')
			end
			
			puts "user.email" + @configurator.user_email
			unless @configurator.user_email.length > 0
				puts "\n What is your email?"
				answer = ""

				loop do
					show_prompt
					answer = gets.downcase.chomp
					break if answer.length > 0

					puts red_bang + "Please enter a email."
				end

				puts ""
				puts green_bang + "Setting your email in git to " + answer
				run_command('git config user.email "' + answer + '"')
			end
		end

		def farewell_message
			puts ""

      		puts " Ace! you're ready to go!"
      		puts " We will start you off by opening your project in Xcode"
      		project_name = @configurator.project_name
      		proj_path = project_name + "/#{project_name}.xcodeproj"
      		workspace_path = project_name + "/#{project_name}.xcworkspace"
      		if File.exist?(workspace_path)
      			run_command "open '#{workspace_path}'"
      		else
      			run_command "open '#{proj_path}'"
      		end
		end
	end
	
end

