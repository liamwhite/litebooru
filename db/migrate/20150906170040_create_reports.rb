class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.string :reason
      t.boolean :open
      t.string :state

      t.timestamps null: false
    end
  end
end
