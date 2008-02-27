#!/usr/bin/env ruby

# Copyright:
#   (c) 2006 syncPEOPLE, LLC.
#   Visit us at http://syncpeople.com/
# Author: Duane Johnson (duane.johnson@gmail.com)
# Description:
#   Makes an intelligent decision on which file to go to based on the current line or current context.

require 'rails_bundle_tools'


current_file = RailsPath.new

if ARGV.empty?
  if current_file.associations[current_file.file_type].nil?
    puts "This file is not associated with any other files" 
    exit
  end
  # Best match
  choice =
    case current_file.file_type
    when :controller
      if current_file.action_name
        :view
      else
        if current_file.rails_path_for(:functional_test).exists?
          :functional_test
        elsif current_file.rails_path_for(:helper).exists?
          :helper
        end
      end
    when :model
      if (path = current_file.rails_path_for(:view)) && path.exists?
        :view
      else
        current_file.associations[current_file.file_type].first
      end
    else
      current_file.associations[current_file.file_type].first
    end
else
  choice = ARGV.shift
end

if rails_path = current_file.rails_path_for(choice.to_sym)
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
