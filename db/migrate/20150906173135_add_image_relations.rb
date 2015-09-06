class AddImageRelations < ActiveRecord::Migration
  def change
    add_column :images, :tag_ids, :integer, array: true
    add_reference :images, :user
    add_reference :images, :hidden_by_user

    add_index :images, :tag_ids, using: :gin
  end
end
