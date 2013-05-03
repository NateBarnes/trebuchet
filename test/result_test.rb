require "test_helper"

class ResultTest < Test::Unit::TestCase
  def setup
    @result = Trebuchet::Result.new
    @parser = Trebuchet::Parser.new(File.open("test/fixtures/siege_output.txt"))
  end

  def test_add_parse
    @result.add_parse @parser
    @result.add_parse @parser
    assert_equal 114, @result.requests
    assert_equal 0, @result.failed_requests
    assert_equal 1.92, @result.rps
  end
end
