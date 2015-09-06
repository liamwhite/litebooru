class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments do |t|
      t.string :body, null: false, default: ""
      t.boolean :hidden_from_users, default: false
      t.time :deleted_at, default: nil

      t.timestamps null: false
    end

    add_index :comments, :created_at
  end
end
