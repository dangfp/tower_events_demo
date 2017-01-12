class CreateProjects < ActiveRecord::Migration[5.0]
  def change
    create_table :projects do |t|
      t.integer  :team_id,                 null: false
      t.integer  :creator_id,              null: false
      t.string   :name,         limit: 20, null: false
      t.string   :description,  limit: 255
      t.integer  :project_type,            null: false
      t.string   :status,       limit: 20, null: false
      t.datetime :deleted_at

      t.timestamps

      t.index [:team_id, :name], unique: true
      t.index :deleted_at
    end
  end
end
