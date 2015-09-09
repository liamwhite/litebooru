class CreateFilters < ActiveRecord::Migration
  def change
    create_table :filters do |t|
      t.string :name, null: false, default: ""
      t.string :description, default: ""
      t.boolean :system, null: false, default: false
      t.boolean :public, null: false, default: false

      t.integer :hidden_tag_ids, null: false, array: true, default: []
      t.integer :spoilered_tag_ids, null: false, array: true, default: []
      t.string :hidden_complex, default: ""
      t.string :spoilered_complex, default: ""

      t.integer :user_count, null: false, default: 0

      t.timestamps null: false
    end

    add_reference :filters, :user
    add_reference :users, :current_filter
  end
end
