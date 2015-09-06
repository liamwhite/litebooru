class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :source_url
      t.string :description
      t.integer :id_number, default: 0
      t.boolean :hidden_from_users
      t.string :hide_reason
      t.integer :comment_count

      t.timestamps null: false
    end

    add_index :images, :id_number, unique: true
    add_index :images, :hidden_from_users
  end
end
