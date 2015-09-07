class RemoveDefaultIdnumber < ActiveRecord::Migration
  def change
    remove_column :images, :id_number
    add_column :images, :id_number, :integer, null: false
    add_index :images, :id_number, unique: true
  end
end
