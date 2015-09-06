class Notification < ActiveRecord::Base
  # Relations
  belongs_to :actor, polymorphic: true
  belongs_to :user
end
