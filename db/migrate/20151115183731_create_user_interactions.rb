class CreateUserInteractions < ActiveRecord::Migration
  def change
    create_table :user_interactions do |t|
      t.string  :interaction_type, null: false
      t.string  :value
      t.references :user
      t.references :image
    end

    add_index :user_interactions, [:image_id, :user_id]
    add_index :user_interactions, [:user_id]

    change_table :images do |t|
      t.integer  :score,           default: 0
      t.integer  :favourites,      default: 0
      t.integer  :up_vote_count,   default: 0
      t.integer  :down_vote_count, default: 0
      t.integer  :vote_count,      default: 0
    end
  end
end
