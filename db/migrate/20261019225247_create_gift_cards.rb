class CreateGiftCards < ActiveRecord::Migration[8.1]
  def change
    create_table :gift_cards do |t|
      t.string :store_name, null: false
      t.string :card_number, null: false
      t.string :pin
      t.decimal :balance, precision: 10, scale: 2, default: 0.0, null: false
      t.string :currency, default: "USD", null: false
      t.date :expiration_date
      t.string :booking_url
      t.boolean :redeemed, default: false, null: false
      t.string :color_theme, default: "emerald"
      t.text :notes

      t.timestamps
    end

    add_index :gift_cards, :redeemed
    add_index :gift_cards, :expiration_date
    add_index :gift_cards, :store_name
  end
end
