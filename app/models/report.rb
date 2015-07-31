class Report
  include Mongoid::Document
  include Mongoid::Timestamps

  field :reason, type: String
  field :open, type: Boolean, default: true
  field :state, type: String, default: 'open'
  field :ip, type: String
  field :user_agent, type: String

  belongs_to :user, inverse_of: :reports_made
  belongs_to :admin, class_name: 'User', inverse_of: :managed_reports
  belongs_to :reportable, polymorphic: true
end
