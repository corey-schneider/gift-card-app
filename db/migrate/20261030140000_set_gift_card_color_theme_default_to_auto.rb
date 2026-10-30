class SetGiftCardColorThemeDefaultToAuto < ActiveRecord::Migration[8.1]
  def change
    change_column_default :gift_cards, :color_theme, from: "emerald", to: "auto"
  end
end
