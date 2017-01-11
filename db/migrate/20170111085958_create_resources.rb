class CreateResources < ActiveRecord::Migration[5.0]
  def change
    create_table :resources do |t|
      t.integer :resourceable_id,              null: false
      t.string  :resourceable_type, limit: 50, null: false

      t.timestamps

      t.index [:resourceable_id, :resourceable_type], unique: true
    end
  end
end
