class Image
  include Mongoid::Document
  include Mongoid::Paperclip
  include Mongoid::Timestamps
  include Reportable

  # Fields
  field :ip, type: String
  field :user_agent, type: String, default: ""
  field :source_url, type: String, default: ""
  field :description, type: String, default: ""
  field :id_number, type: Integer
  field :hidden_from_users, type: Boolean, default: false
  field :hide_reason, type: String

  # Indexes
  index id_number: 1
  index tag_ids: 1
  index hidden_from_users: 1

  # Relations
  has_and_belongs_to_many :tags, validate: false, inverse_of: nil
  belongs_to :user, inverse_of: :images
  belongs_to :hidden_by_user, class_name: 'User', inverse_of: :hidden_images

  has_mongoid_attached_file :image, presence: true, styles: {thumb_tiny: '50x50>', thumb_small: '150x150>', thumb: '250x250>', small: '320x240>', medium: '800x600>', large: '1280x1024>', tall: '1024x4096>'}
  validates_attachment :image, content_type: {content_type: %w|image/png image/jpeg image/gif|}, size: {in: 0..25000.kilobytes}
end
