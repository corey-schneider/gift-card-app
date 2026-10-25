require "test_helper"

class GiftCardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    AppSetting.set_passcode("1234")
    @card = GiftCard.create!(
      store_name: "Apple Store",
      card_number: "6011 9988 7766 1234",
      pin: "5678",
      balance: 150.00,
      expiration_date: Date.current + 60.days,
      booking_url: "https://apple.com",
      redeemed: false
    )
  end

  test "index displays public information without requiring login" do
    get root_url
    assert_response :success

    # Public info is visible
    assert_includes response.body, "Apple Store"
    assert_includes response.body, "$150.00"

    # Sensitive info is masked when locked
    assert_includes response.body, "•••• •••• •••• 1234"
    assert_not_includes response.body, "6011 9988 7766 1234"
    assert_not_includes response.body, ">5678<"
    assert_match(/<form[^>]*id="card-active-form"[^>]*data-turbo="false"/, response.body)
  end

  test "index displays decrypted card number and pin when session is unlocked" do
    # Unlock session
    post unlock_url, params: { pin: "1234" }
    assert session[:unlocked_until].present?

    get root_url
    assert_response :success

    # Sensitive info is now revealed
    assert_includes response.body, "6011 9988 7766 1234"
    assert_includes response.body, "5678"
  end

  test "creates new gift card" do
    assert_difference("GiftCard.count", 1) do
      post gift_cards_url, params: {
        gift_card: {
          store_name: "Chipotle",
          card_number: "1122 3344 5566 7788",
          pin: "9900",
          balance: 35.50,
          color_theme: "amber"
        }
      }
    end

    assert_redirected_to root_url
    new_card = GiftCard.find_by(store_name: "Chipotle")
    assert_equal "1122 3344 5566 7788", new_card.card_number
  end

  test "creates new certificate without balance" do
    assert_difference("GiftCard.count", 1) do
      post gift_cards_url, params: {
        gift_card: {
          store_name: "Blue Sky Adventures",
          card_number: "SKY-9988",
          value_description: "Buy 1 Get 1 Free",
          balance: "",
          color_theme: "navy"
        }
      }
    end

    assert_redirected_to root_url
    new_card = GiftCard.find_by(store_name: "Blue Sky Adventures")
    assert_nil new_card.balance
    assert_equal "Buy 1 Get 1 Free", new_card.value_description
  end

  test "updates existing gift card" do
    patch gift_card_url(@card), params: {
      gift_card: {
        balance: 75.00
      }
    }

    assert_response :see_other
    assert_redirected_to root_url
    assert_equal 75.00, @card.reload.balance

    follow_redirect!
    assert_response :success
    assert_includes response.body, "$75.00"
  end

  test "toggles redeemed status" do
    assert_not @card.redeemed?

    patch toggle_redeemed_gift_card_url(@card)
    assert_redirected_to root_url
    assert @card.reload.redeemed?

    patch toggle_redeemed_gift_card_url(@card)
    assert_redirected_to root_url
    assert_not @card.reload.redeemed?
  end

  test "deletes gift card" do
    assert_difference("GiftCard.count", -1) do
      delete gift_card_url(@card)
    end

    assert_redirected_to root_url
  end
end
