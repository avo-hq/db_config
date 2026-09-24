require "test_helper"
require "open3"

class RequireTest < ActiveSupport::TestCase
  # This process already booted the dummy app, so the require is checked in a fresh one.
  test "requiring the gem does not load Active Record" do
    script = 'require "rails"; require "active_record"; require "db_config"; ' \
      'puts $LOADED_FEATURES.any? { _1.end_with?("active_record/base.rb") }'
    output, status = Open3.capture2e(RbConfig.ruby, "-I", File.expand_path("../lib", __dir__), "-e", script)

    assert status.success?, output
    assert_equal "false", output.lines.last.strip
  end
end
