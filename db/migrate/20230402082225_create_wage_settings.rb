class CreateWageSettings < ActiveRecord::Migration[6.0]
  def change
    create_table :wage_settings do |t|
      t.integer :base
      t.float :night_rate
      t.time :night_start
      t.time :night_end
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
