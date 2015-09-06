class AddReportRelations < ActiveRecord::Migration
  def change
    add_reference :reports, :user
    add_reference :reports, :admin
    add_reference :reports, :reportable, polymorphic: true
  end
end
