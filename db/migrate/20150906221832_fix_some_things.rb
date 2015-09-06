class FixSomeThings < ActiveRecord::Migration
  def change
    remove_column :tags, :short_descripion, :string
    remove_column :tags, :description, :string
    add_column :tags, :short_description, :string, null: false, default: ""
    add_column :tags, :description, :string, null: false, default: ""
    
    remove_column :images, :watcher_ids, :integer
    remove_column :images, :tag_ids, :integer
    remove_column :images, :hidden_from_users, :boolean
    add_column :images, :watcher_ids, :integer, null: false, array: true, default: []
    add_column :images, :tag_ids, :integer, null: false, array: true, default: []
    add_column :images, :hidden_from_users, :boolean, null: false

    remove_column :users, :unread_notification_ids, :integer
    add_column :users, :unread_notification_ids, :integer, null: false, array: true, default: []

    add_index :images, :tag_ids, using: :gin
    add_index :images, :hidden_from_users
    add_index :users, :unread_notification_ids, using: :gin
  end
end
