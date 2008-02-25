#!/usr/bin/env ruby

# Copyright:
#   (c) 2006 syncPEOPLE, LLC.
#   Visit us at http://syncpeople.com/
# Author: Duane Johnson (duane.johnson@gmail.com)
# Description:
#   Asks what to generate and what name to use, then runs script/generate.

require 'rails_bundle_tools'
require 'fileutils'
require File.dirname(__FILE__) + "/../lib/rails/generate"

# Look for (created) files and return an array of them
def files_from_generator_output(output, type = 'create')
  output.to_a.map { |line| line.scan(/#{type}\s+([^\s]+)$/).flatten.first }.compact.select { |f| File.exist?(f) and !File.directory?(f) }
end

def ruby(command)
  `/usr/bin/env ruby #{command}`
end

Generator.setup

if choice = TextMate.choose("Generate:", Generator.names, :title => "Rails Generator")
  name =
    TextMate.input(
      Generator.generators[choice].question,
      Generator.generators[choice].default_answer,
      :title => "#{Generator.generators[choice].name.capitalize} Generator")
  if name
    options = ""

    case choice
    when 0
      options = TextMate.input("Name the new controller for the scaffold:", "", :title => "Scaffold Controller Name")
      options = "'#{options}'"
    when 1
      options = TextMate.input("List any actions you would like created for the controller:",
        "index new create edit update destroy", :title => "Controller Actions")
    end

    # add the --svn option, if needed
    proj_dir = ENV["TM_PROJECT_DIRECTORY"]
    if proj_dir and File.exist?(File.join(proj_dir, ".svn"))
      options << " --svn"
    end

    rails_root = RailsPath.new.rails_root
    FileUtils.cd rails_root
    command = "\"script/generate\" #{generators[choice].name} #{name} #{options}"
    $logger.debug "Command: #{command}"

    output = ruby(command)
    $logger.debug "Output: #{output}"
    TextMate.refresh_project_drawer
    files = files_from_generator_output(output)
    files.each { |f| TextMate.open(File.join(rails_root, f)) }
    TextMate.textbox("Done generating #{generators[choice].name}", output, :title => "Done")
  end
end
