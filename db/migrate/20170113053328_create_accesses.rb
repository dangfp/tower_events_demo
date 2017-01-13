class CreateAccesses < ActiveRecord::Migration[5.0]
  def change
    create_table :accesses do |t|
      t.integer :user_id,     null: false
      t.integer :resource_id, null: false

      t.timestamps

      t.index :user_id
    end
  end
end
