class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :document, null: false, index: { unique: true }
      t.date :date_of_birth, null: false

      t.timestamps
    end
    add_index :users, :email, unique: true
  end
end
