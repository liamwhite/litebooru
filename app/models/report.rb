class Report < ActiveRecord::Base
  include UserAttributable

  # Relations
  belongs_to :user, inverse_of: :reports_made
  belongs_to :admin, class_name: 'User', inverse_of: :managed_reports
  belongs_to :reportable, polymorphic: true
end
