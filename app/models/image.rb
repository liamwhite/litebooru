class Image < ActiveRecord::Base
  include AnonymizableUserAttributable
  include Notifyable
  include Reportable

  # Relations
  has_many :comments, validate: false
  belongs_to :user, inverse_of: :images
  belongs_to :hidden_by_user, class_name: 'User', inverse_of: :hidden_images
end
