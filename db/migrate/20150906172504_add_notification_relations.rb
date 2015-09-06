class AddNotificationRelations < ActiveRecord::Migration
  def change
    add_reference :notifications, :user
    add_reference :notifications, :actor

    add_index :notifications, [:user_id, :created_at]
  end
end
