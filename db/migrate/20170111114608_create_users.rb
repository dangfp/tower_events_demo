class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :name,            limit: 20,  null: false
      t.string :email,           limit: 100, null: false
      t.string :avatar,          limit: 255
      t.string :password_digest, limit: 64,  null: false
      t.string :memo,            limit: 255

      t.timestamps

      t.index :email, unique: true
    end
  end
end
