class CreateEmployees < ActiveRecord::Migration[6.0]
  def change
    create_table :employees do |t|
      t.string :name
      t.integer :password
      t.integer :wage
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
