require "test_helper"

class GiftCardTest < ActiveSupport::TestCase
  test "validates required fields and allows optional balance" do
    card = GiftCard.new
    assert_not card.valid?
    assert_includes card.errors[:store_name], "can't be blank"
    assert_includes card.errors[:card_number], "can't be blank"

    card.store_name = "Target"
    card.card_number = "12345678"
    card.balance = -5
    assert_not card.valid?
    assert_includes card.errors[:balance], "must be greater than or equal to 0"

    # Balance is optional for certificates / BOGO vouchers
    card.balance = nil
    card.value_description = "Buy 1 Get 1 Free"
    assert card.valid?

    card.balance = 25.0
    assert card.valid?
  end

  test "encrypts card number and pin at rest" do
    card = GiftCard.create!(
      store_name: "Best Buy",
      card_number: "9988776655443322",
      pin: "4321",
      balance: 100.0
    )

    # Decrypted in memory
    assert_equal "9988776655443322", card.card_number
    assert_equal "4321", card.pin

    # Verify directly from raw database column
    raw_row = ActiveRecord::Base.connection.execute(
      "SELECT card_number, pin FROM gift_cards WHERE id = #{card.id}"
    ).first

    raw_card_number = raw_row["card_number"]
    raw_pin = raw_row["pin"]

    # Must NOT equal plain text!
    assert_not_equal "9988776655443322", raw_card_number
    assert_not_equal "4321", raw_pin

    # Must be encrypted JSON ciphertext payload
    assert_includes raw_card_number, "\"p\":"
    assert_includes raw_pin, "\"p\":"
  end

  test "masked_card_number masks sensitive digits" do
    card = GiftCard.new(card_number: "6011 4820 9931 4022")
    assert_equal "•••• •••• •••• 4022", card.masked_card_number

    short_card = GiftCard.new(card_number: "123")
    assert_equal "••••", short_card.masked_card_number
  end

  test "sorting scopes" do
    card1 = GiftCard.create!(store_name: "Zeta Store", card_number: "1111", balance: 10, expiration_date: Date.current + 30.days)
    card2 = GiftCard.create!(store_name: "Alpha Store", card_number: "2222", balance: 50, expiration_date: Date.current + 5.days)
    card3 = GiftCard.create!(store_name: "Beta Store", card_number: "3333", balance: 100, expiration_date: nil)

    # expiring_first scope: soonest expiration first
    exp_first = GiftCard.where(id: [card1.id, card2.id, card3.id]).expiring_first
    assert_equal card2.id, exp_first.first.id # +5 days
    assert_equal card1.id, exp_first.second.id # +30 days
    assert_equal card3.id, exp_first.third.id # nil expiration

    # name_asc: Alpha, Beta, Zeta
    by_name = GiftCard.where(id: [card1.id, card2.id, card3.id]).by_sort("name_asc")
    assert_equal ["Alpha Store", "Beta Store", "Zeta Store"], by_name.map(&:store_name)

    # amount_desc: 100, 50, 10
    by_amount = GiftCard.where(id: [card1.id, card2.id, card3.id]).by_sort("amount_desc")
    assert_equal [100.0, 50.0, 10.0], by_amount.map(&:balance).map(&:to_f)

    # card without balance is sorted last in amount_desc
    voucher = GiftCard.create!(store_name: "Skydiving", card_number: "SKYDIVE1", balance: nil, value_description: "BOGO")
    with_voucher = GiftCard.where(id: [card1.id, card2.id, voucher.id]).by_sort("amount_desc")
    assert_equal voucher.id, with_voucher.last.id
  end

  test "search filters by store name, notes, and value_description" do
    card1 = GiftCard.create!(store_name: "Nordstrom", card_number: "1234", balance: 50, notes: "Anniversary gift")
    card2 = GiftCard.create!(store_name: "Macy's", card_number: "5678", balance: 25, notes: "General shopping")
    card3 = GiftCard.create!(store_name: "Adventure Co", card_number: "9999", balance: nil, value_description: "Skydiving Jump")

    results = GiftCard.where(id: [card1.id, card2.id, card3.id]).search("nord")
    assert_includes results, card1
    assert_not_includes results, card2

    results_notes = GiftCard.where(id: [card1.id, card2.id, card3.id]).search("anniversary")
    assert_includes results_notes, card1
    assert_not_includes results_notes, card2

    results_perk = GiftCard.where(id: [card1.id, card2.id, card3.id]).search("skydiving")
    assert_includes results_perk, card3
    assert_not_includes results_perk, card1
  end
end
