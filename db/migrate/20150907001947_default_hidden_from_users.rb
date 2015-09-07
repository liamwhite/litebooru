class DefaultHiddenFromUsers < ActiveRecord::Migration
  def change
    remove_column :images, :hidden_from_users, :boolean
    add_column :images, :hidden_from_users, :boolean, null: false, default: false
    add_index :images, :hidden_from_users
  end
end
