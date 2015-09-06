class Comment < ActiveRecord::Base
  include AnonymizableUserAttributable
  include Reportable

  # Relations
  belongs_to :user, validate: false
  belongs_to :image, validate: false
  belongs_to :deleted_by, class_name: "User"
end
