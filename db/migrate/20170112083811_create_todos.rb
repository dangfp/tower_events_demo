class CreateTodos < ActiveRecord::Migration[5.0]
  def change
    create_table :todos do |t|
      t.integer  :project_id,               null: false
      t.integer  :creator_id,               null: false
      t.string   :name,          limit: 50, null: false
      t.string   :description,   limit: 255
      t.integer  :assignee_id
      t.string   :assignee_name, limit: 20
      t.date     :due
      t.string   :priority,      limit: 10
      t.string   :status,        limit: 20, null: false
      t.string   :tag,           limit: 50
      t.datetime :deleted_at

      t.timestamps

      t.index [:project_id, :name], unique: true
      t.index [:project_id, :creator_id]
      t.index :deleted_at
    end
  end
end
