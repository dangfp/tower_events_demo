class CreateEvents < ActiveRecord::Migration[5.0]
  def change
    create_table :events do |t|
      t.integer :team_id,                     null: false
      t.integer :resource_id,                 null: false
      t.integer :actor_id,                    null: false
      t.string  :actor_name,     limit: 20,   null: false
      t.string  :actor_avatar,   limit: 255,  null: false
      t.string  :action,         limit: 50,   null: false
      t.integer :trackable_id,                null: false
      t.string  :trackable_type, limit: 50,   null: false
      t.string  :trackable_name, limit: 50,   null: false
      t.integer :ancestor_id,                 null: false
      t.string  :ancestor_type,  limit: 50,   null: false
      t.string  :ancestor_name,  limit: 50,   null: false
      t.string  :data,           limit: 1000
      t.string  :ip,             limit: 100
      t.string  :user_agent,     limit: 1000

      t.timestamps

      t.index [:team_id, :resource_id]
    end
  end
end
