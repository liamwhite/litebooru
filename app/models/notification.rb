class Notification
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  # Fields
  field :action, type: String

  # Relations
  belongs_to :actor, polymorphic: true, index: true
  belongs_to :user

  # Indexes
  index user_id: 1, created_at: -1
end
