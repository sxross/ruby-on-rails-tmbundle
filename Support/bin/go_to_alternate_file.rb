#!/usr/bin/env ruby

# Copyright:
#   (c) 2006 syncPEOPLE, LLC.
#   Visit us at http://syncpeople.com/
# Author: Duane Johnson (duane.johnson@gmail.com)
# Description:
#   Makes an intelligent decision on which file to go to based on the current line or current context.

require 'rails_bundle_tools'

current_file = RailsPath.new

choice = ARGV.empty? ? current_file.best_match : ARGV.shift
              
if choice.nil?
  puts "This file is not associated with any other files" 
elsif rails_path = current_file.rails_path_for(choice.to_sym)
  if choice.to_sym == :view and !rails_path.exists?
    if filename = TextMate.input("Enter the name of the new view file:", rails_path.basename)
      rails_path = RailsPath.new(File.join(rails_path.dirname, filename))
    else
      TextMate.exit_discard
    end
  end
  
  if !rails_path.exists?
    rails_path.touch
    TextMate.refresh_project_drawer
  end
 
  TextMate.open rails_path
else
  puts "#{current_file.basename} does not have a #{choice}"
end
