# Seed initial sample cards and default PIN for instant testing

AppSetting.set_passcode("1234") unless AppSetting.passcode_set?

sample_cards = [
  {
    store_name: "Target",
    card_number: "6011 4820 9931 4022",
    pin: "8841",
    balance: 50.00,
    expiration_date: Date.current + 14.days, # Expiring soon
    color_theme: "rose",
    booking_url: "https://www.target.com",
    redeemed: false,
    notes: "Birthday gift from Mom"
  },
  {
    store_name: "Starbucks",
    card_number: "6082 1290 8472 9015",
    pin: "3219",
    balance: 25.50,
    expiration_date: Date.current + 90.days,
    color_theme: "emerald",
    booking_url: "https://app.starbucks.com",
    redeemed: false,
    notes: "Reloadable digital card"
  },
  {
    store_name: "Amazon",
    card_number: "AQ29-XJ48-91KM-02P9",
    pin: "",
    balance: 100.00,
    expiration_date: nil, # Never expires
    color_theme: "amber",
    booking_url: "https://www.amazon.com/gc/redeem",
    redeemed: false,
    notes: "No expiration date"
  },
  {
    store_name: "Apple Store",
    card_number: "X902 4410 8821 7730",
    pin: "1928",
    balance: 150.00,
    expiration_date: Date.current + 365.days,
    color_theme: "slate",
    booking_url: "https://www.apple.com",
    redeemed: false,
    notes: "Saved for new AirPods"
  },
  {
    store_name: "Delta Air Lines",
    card_number: "0062 8840 1928 3391",
    pin: "4402",
    balance: 200.00,
    expiration_date: Date.current - 10.days, # Expired card
    color_theme: "indigo",
    booking_url: "https://www.delta.com",
    redeemed: true,
    notes: "Redeemed for flight to Chicago"
  }
]

sample_cards.each do |attrs|
  GiftCard.find_or_create_by!(store_name: attrs[:store_name], card_number: attrs[:card_number]) do |c|
    c.pin = attrs[:pin]
    c.balance = attrs[:balance]
    c.expiration_date = attrs[:expiration_date]
    c.color_theme = attrs[:color_theme]
    c.booking_url = attrs[:booking_url]
    c.redeemed = attrs[:redeemed]
    c.notes = attrs[:notes]
  end
end

puts "Seeded #{GiftCard.count} gift cards successfully! Default master PIN is 1234."
