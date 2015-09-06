class CreateTags < ActiveRecord::Migration
  def change
    create_table :tags do |t|
      t.string :description
      t.integer :image_count
      t.string :name
      t.string :namespace
      t.string :name_in_namespace
      t.string :short_descripion
      t.boolean :system
      t.string :slug

      t.timestamps null: false
    end

    add_index :tags, :name
    add_index :tags, :system
    add_index :tags, :slug
  end
end
