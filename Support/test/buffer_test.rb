require 'test_helper'

require 'text_mate_mock'
require 'rails/buffer'

TextMate.line_number = '1'
TextMate.column_number = '1'
TextMate.selected_text = <<-END
def my_method
  puts 'hi'
  # some comment, 'hi'
end

def my_other_method
  x = y + z
  # another comment
end
END

class BufferTest < Test::Unit::TestCase
  def test_find
    b = Buffer.new(TextMate.selected_text)
    match = b.find { /'(.+)'/ }
    assert_equal [1, "hi"], match

    match = b.find(:from => 2, :to => 1, :direction => :backwards) { /'(.+)'/ }
    assert_equal [2, "hi"], match

    match = b.find(:from => 2, :to => 1, :direction => :backwards) { /my_method/ }
    assert_nil match
  end
  
  def test_find_method
    b = Buffer.new(TextMate.selected_text)
    match = b.find { /def\s+my_(.+)\W/ }
    assert_equal [0, 'method'], match
    
    b.line_number = 4
    match = b.find(:direction => :backwards) { /def\s+my_(.+)\W/ }
    assert_equal [0, 'method'], match

    b.line_number = 5
    match = b.find(:direction => :backwards) { /def\s+my_(.+)\W/ }
    assert_equal [5, 'other_method'], match
  end      
  
  def test_find_multiple_matches
    b = Buffer.new(TextMate.selected_text)
    match = b.find { /^\s*x = (\w) \+ (\w)\s*$/ }
    assert_equal [6, 'y', 'z'], match

    b = Buffer.new(TextMate.selected_text)
    match = b.find { /^\s*x = (\w) \+ (\w)(\w?)\s*$/ }
    assert_equal [6, 'y', 'z', ''], match
  end
  
  def test_find_nearest_string_or_symbol
    b = Buffer.new "String :with => 'strings', :and, :symbols"
    match = b.find_nearest_string_or_symbol
    assert_equal ["with", 8], match
    
    b.column_number = 8
    match = b.find_nearest_string_or_symbol
    assert_equal ["with", 8], match

    b.column_number = 25
    match = b.find_nearest_string_or_symbol
    assert_equal ["strings", 17], match

    b.column_number = 37
    match = b.find_nearest_string_or_symbol
    assert_equal ["symbols", 34], match
    
    b = Buffer.new "String without symbols or strings"
    match = b.find_nearest_string_or_symbol
    assert_nil match
  end
end