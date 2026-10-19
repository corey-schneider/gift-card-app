# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_10_19_225251) do
  create_table "app_settings", force: :cascade do |t|
    t.string "passcode_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "gift_cards", force: :cascade do |t|
    t.string "store_name", null: false
    t.string "card_number", null: false
    t.string "pin"
    t.decimal "balance", precision: 10, scale: 2, default: "0.0", null: false
    t.string "currency", default: "USD", null: false
    t.date "expiration_date"
    t.string "booking_url"
    t.boolean "redeemed", default: false, null: false
    t.string "color_theme", default: "emerald"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expiration_date"], name: "index_gift_cards_on_expiration_date"
    t.index ["redeemed"], name: "index_gift_cards_on_redeemed"
    t.index ["store_name"], name: "index_gift_cards_on_store_name"
  end
end
