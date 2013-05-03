require "test_helper"

class ParserTest < Test::Unit::TestCase
  def setup
    @parser = Trebuchet::Parser.new(File.open("test/fixtures/siege_output.txt"))
  end

  def test_requests
    assert_equal 57, @parser.requests
  end

  def test_failed_requests
    assert_equal 0, @parser.failed_requests
  end

  def test_rps
    assert_equal 0.96, @parser.rps
  end
end

