require 'test_helper'

class ToolTest < ActiveSupport::TestCase
	test "empty tool without name should not save" do
		tool = Tool.new
		assert !tool.save
	end

	test "completed valid tool should save" do
		tool = Tool.new
		tool.name = "Test Tool"
		tool.url = "http://www.google.com"
		assert tool.save
	end

	test "tool with invalid url does not save" do
		tool = Tool.new
		tool.name = "Test Tool"
		tool.url = "invalid url"
		assert !tool.save
	end
end
