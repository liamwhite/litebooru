class AddCommentRelations < ActiveRecord::Migration
  def change
    add_reference :comments, :user
    add_reference :comments, :image
    add_reference :comments, :deleted_by

    add_index :comments, [:image_id, :created_at]
  end
end
