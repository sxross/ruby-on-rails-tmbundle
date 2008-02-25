require File.dirname(__FILE__) + '/test_helper'
require "rails/generate"

class TestBinGenerate < Test::Unit::TestCase
  def test_known_generators
    expected = %w[scaffold controller model mailer migration plugin]
    actual = Generator.known_generators.map { |gen| gen.name }
    assert_equal(expected, actual)
  end
end