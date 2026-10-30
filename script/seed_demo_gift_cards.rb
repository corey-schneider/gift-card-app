require "securerandom"

unless Rails.env.development?
  raise "Demo gift cards can only be seeded in the development environment."
end

demo_marker = "[DEMO MERCHANT SEED]"
expiration_offsets = [-30, 14, 60, 180, 365, nil]
notes = [
  "Generated for checking the merchant logo and card finish.",
  "Sample data for reviewing the card layout.",
  "Development-only demo card."
]

created_count = 0
skipped_count = 0

GiftCard::MERCHANT_NAMES.each do |merchant|
  already_seeded = GiftCard.where(store_name: merchant)
    .where("notes LIKE ?", "#{demo_marker}%")
    .exists?

  if already_seeded
    skipped_count += 1
    next
  end

  expiration_offset = expiration_offsets.sample
  balance = BigDecimal("#{rand(5..200)}.#{format('%02d', rand(100))}")

  GiftCard.create!(
    store_name: merchant,
    card_number: "DEMO-#{SecureRandom.hex(6).upcase}",
    pin: "DEMO#{SecureRandom.hex(2).upcase}",
    balance: balance,
    currency: "USD",
    expiration_date: expiration_offset && Date.current + expiration_offset.days,
    booking_url: "https://example.com/demo-gift-card",
    redeemed: false,
    color_theme: "auto",
    value_description: ["Demo balance", "Sample gift card", "Layout preview"].sample,
    notes: "#{demo_marker} #{notes.sample}"
  )

  created_count += 1
end

puts "Created #{created_count} demo gift cards; skipped #{skipped_count} already-seeded merchants."
