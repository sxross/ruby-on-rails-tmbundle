#!/usr/bin/env ruby

require 'rails_bundle_tools'
require 'yaml'
require 'rubygems'
require 'active_support/inflector'
require File.join(ENV['TM_SUPPORT_PATH'], "lib", "escape")
DIALOG = ENV['DIALOG']

def find_foreign_key_reference_name
  current_line = TextMate.current_line
  line_parts = current_line.split(":")
  line_parts[0].lstrip
end

def load_referenced_fixture_file(ref)
  ref_plural = Inflector.pluralize(find_foreign_key_reference_name)
  ref_file = File.join(TextMate.project_directory, "test", "fixtures", "#{ref_plural}.yml")
  if (!File.exist?(ref_file))
    puts "Could not find any #{ref} fixtures."
    TextMate.exit_show_tool_tip
  end
  YAML.load_file(ref_file)
end

def ask_for_fixture(fixtures)
  require "#{ENV['TM_SUPPORT_PATH']}/lib/osx/plist"
  h = fixtures.map do |f|
    {'title' => f, 'fixture' => f}
  end
  pl = {'menuItems' => h}.to_plist
  res = OSX::PropertyList::load(`#{e_sh DIALOG} -up #{e_sh pl}`)
  TextMate.exit_discard unless res.has_key? 'selectedMenuItem'
  res['selectedMenuItem']['fixture']
end

ref = find_foreign_key_reference_name
foreign_fixtures = load_referenced_fixture_file(ref)
selected_fixture = ask_for_fixture(foreign_fixtures.keys)
print "  #{ref}: #{selected_fixture}"
