class UserInteraction < ActiveRecord::Base
  belongs_to :user
  belongs_to :image
  validates :user_id, uniqueness: {scope: [:image_id, :interaction_type]}
end
