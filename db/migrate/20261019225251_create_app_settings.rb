class CreateAppSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :app_settings do |t|
      t.string :passcode_digest

      t.timestamps
    end
  end
end
