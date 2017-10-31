#!/usr/bin/env ruby

$current_dir = File.dirname(File.expand_path(__FILE__))
Dir[File.join($current_dir, "setup/*.rb")].each do |file|
	require_relative(file)
end

project_name = ARGV.shift
Project::TemplateConfigurator.new(project_name).run