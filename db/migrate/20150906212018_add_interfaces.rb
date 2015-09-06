class AddInterfaces < ActiveRecord::Migration
  def change
    add_column :images, :watcher_ids, :integer, array: true
    add_column :images, :ip, :inet
    add_column :images, :user_agent, :string
    add_column :images, :anonymous, :boolean

    add_column :comments, :ip, :inet
    add_column :comments, :user_agent, :string
    add_column :comments, :anonymous, :boolean

    add_column :reports, :ip, :inet
    add_column :reports, :user_agent, :string

    add_column :users, :unread_notification_ids, :integer, array: true
    add_index  :users, :unread_notification_ids, using: :gin
  end
end
