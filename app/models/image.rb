class Image
  include Mongoid::Document
  include Mongoid::Timestamps
  include Reportable

  field :ip, type: String
  field :user_agent, type: String, default: ""
  field :source_url, type: String, default: ""
  field :description, type: String, default: ""
  field :id_number, type: Integer
  field :hidden_from_users, type: Boolean, default: false
  field :hide_reason, type: String

  index id_number: 1
  index tag_ids: 1
  index hidden_from_users: 1

  has_and_belongs_to_many :tags, validate: false, inverse_of: nil
  belongs_to :user, inverse_of: :images
  belongs_to :hidden_by_user, class_name: 'User', inverse_of: :hidden_images
end
