class ChangeBalanceAndAddValueDescriptionToGiftCards < ActiveRecord::Migration[8.1]
  def change
    change_column_null :gift_cards, :balance, true
    change_column_default :gift_cards, :balance, from: "0.0", to: nil
    add_column :gift_cards, :value_description, :string
  end
end
