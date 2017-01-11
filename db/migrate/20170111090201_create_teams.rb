class CreateTeams < ActiveRecord::Migration[5.0]
  def change
    create_table :teams do |t|
      t.integer :creator_id,            null: false
      t.string  :title,      limit: 20, null: false

      t.timestamps

      t.index [:creator_id, :title], unique: true
    end
  end
end
