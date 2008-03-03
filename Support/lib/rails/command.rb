class Command
  def self.go_to_alternate_file(args)
    current_file = RailsPath.new

    choice = args.empty? ? current_file.best_match : args.shift

    if choice.nil?
      puts "This file is not associated with any other files"
    elsif rails_path = current_file.rails_path_for(choice.to_sym)    
      if !rails_path.exists?
        rails_path, openatline, openatcol = create_file(rails_path, choice.to_sym)
        if rails_path.nil?
          TextMate.exit_discard
        end
        TextMate.refresh_project_drawer
      end

      TextMate.open rails_path, openatline, openatcol
    else
      puts "#{current_file.basename} does not have a #{choice}"
    end
  end
  
  protected
  
  # Returns the rails_path of the newly created file plus the position 
  # (zero based) in the file where to place the caret after opening the 
  # new file. Returns nil when no new file is created.
  def self.create_file(rails_path, choice)       
    return nil if rails_path.exists?
    if choice == :view 
      filename = TextMate.input("Enter the name of the new view file:", rails_path.basename)
      return nil if !filename
      rails_path = RailsPath.new(File.join(rails_path.dirname, filename))
      rails_path.touch
      return [rails_path, 0, 0]
    end
  
    if !TextMate.message_ok_cancel("Create missing #{rails_path.basename}?")
      return nil
    end

    generated_code, openatline, openatcol = case choice
    when :controller 
      ["class #{rails_path.controller_name.camelize}Controller < ApplicationController\n\nend", 1, 0]
    when :helper
      ["module #{rails_path.controller_name.camelize}Helper\n\nend", 1, 0]
    when :unit_test
      ["require File.dirname(__FILE__) + '/../test_helper'

class #{Inflector.singularize(rails_path.controller_name).camelize}Test < ActiveSupport::TestCase
 # Replace this with your real tests.
 def test_truth
   assert true
 end
end", 3, 0]   
    when :functional_test
      ["require File.dirname(__FILE__) + '/../test_helper'

class #{rails_path.controller_name.camelize}ControllerTest < ActionController::TestCase     

end", 3, 0]
    end

    rails_path.touch
    rails_path.append generated_code if generated_code
    return [rails_path, openatline, openatcol]
  end
    
end