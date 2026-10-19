require "test_helper"

class UnlocksControllerTest < ActionDispatch::IntegrationTest
  setup do
    AppSetting.set_passcode("1234")
  end

  test "unlock with correct PIN sets session for 5 minutes" do
    post unlock_url, params: { pin: "1234" }

    assert_redirected_to root_url
    assert session[:unlocked_until].present?
    assert session[:unlocked_until] > Time.current.to_i
    assert_in_delta 5.minutes.from_now.to_i, session[:unlocked_until], 5
  end

  test "unlock with incorrect PIN via turbo stream fails with 422 and leaves session locked" do
    post unlock_url, params: { pin: "9999" }, as: :turbo_stream

    assert_response :unprocessable_entity
    assert_nil session[:unlocked_until]
  end

  test "unlock with incorrect PIN via html redirects with alert" do
    post unlock_url, params: { pin: "9999" }

    assert_redirected_to root_url
    assert_equal "Incorrect PIN code. Please try again.", flash[:alert]
    assert_nil session[:unlocked_until]
  end

  test "lock clears session" do
    post unlock_url, params: { pin: "1234" }
    assert session[:unlocked_until].present?

    delete lock_url
    assert_redirected_to root_url
    assert_nil session[:unlocked_until]
  end

  test "update_passcode changes master PIN" do
    post unlock_url, params: { pin: "1234" }

    post set_passcode_url, params: { current_pin: "1234", new_pin: "7777" }
    assert_redirected_to root_url

    assert AppSetting.authenticate("7777")
    assert_not AppSetting.authenticate("1234")
  end
end
