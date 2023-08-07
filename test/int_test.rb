require "test_helper"

class IntTest < Test::Unit::TestCase
  test "VERSION" do
    assert do
      ::Int.const_defined?(:VERSION)
    end
  end

  test "something useful" do
    assert_equal(true, !!!false)
  end
end
