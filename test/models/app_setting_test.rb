require "test_helper"

class AppSettingTest < ActiveSupport::TestCase
  test "sets and authenticates passcode" do
    AppSetting.set_passcode("5678")

    assert AppSetting.passcode_set?
    assert AppSetting.authenticate("5678")
    assert_not AppSetting.authenticate("0000")
    assert_not AppSetting.authenticate("")
    assert_not AppSetting.authenticate(nil)
  end

  test "supports ENV APP_UNLOCK_PIN override" do
    begin
      ENV["APP_UNLOCK_PIN"] = "9999"
      assert AppSetting.authenticate("9999")
      assert_not AppSetting.authenticate("1234")
    ensure
      ENV.delete("APP_UNLOCK_PIN")
    end
  end
end
