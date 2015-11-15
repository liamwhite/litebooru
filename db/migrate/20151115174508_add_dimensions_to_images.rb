class AddDimensionsToImages < ActiveRecord::Migration
  def change
    add_column :images, :dimensions, :string
  end
end
