class Image
  include Mongoid::Document
  include Mongoid::Paperclip
  include Mongoid::Timestamps
  include Indexable
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

  # Validations
  validates_attachment :image, content_type: {content_type: %w|image/png image/jpeg image/gif|}, size: {in: 0..25000.kilobytes}
  validates_uniqueness_of :id_number

  ALLOWED_PARAMETERS = [:description, :image, :source_url, :tag_list]

  # Callbacks
  before_create do
    return true if self.id_number
    last_image = Image.desc(:id_number).only(:id_number).first
    if last_image and last_image.id_number and last_image.id_number >= 0
      self.id_number = last_image.id_number+1
    else
      self.id_number = 0
    end
  end

  def to_param
    id_number.to_s
  end

  def tag_list=(tag_list)
    self.tags = Tag.tag_string_to_tags(tag_list)
    @tag_list = self.tags.map(&:name).join(',')
  end

  def tag_list
    @tag_list ||= self.tags.map(&:name).join(',')
  end

  # Elasticsearch
  def as_json(options = {})
    d = {
      id: self.id.to_s,
      id_number: self.id_number,
      created_at: self.created_at,
      updated_at: self.updated_at,
      description: self.description,
      ip: self.ip,
      hidden_from_users: self.hidden_from_users,
      source_url: self.source_url,
      tag_ids: self.tags.map{|t| t.id.to_s},
      tag_names: self.tags.map(&:name),
      uploader: self.user.try(:name).to_s,
      uploader_id: self.user_id.to_s,
    }
  end

  alias as_indexed_json as_json

  settings index: { number_of_shards: 1 } do
    mappings dynamic: 'false', _all: {enabled: false} do
      indexes :id, type: 'string', index: 'not_analyzed'
      indexes :id_number, type: 'integer', index: 'not_analyzed'
      indexes :hidden_from_users, type: 'boolean', index: 'not_analyzed'
      indexes :created_at, type: 'date'
      indexes :updated_at, type: 'date'
      indexes :description, type: 'string', analyzer: 'snowball'
      indexes :ip, type: 'string', index: 'not_analyzed'
      indexes :source_url, type: 'string', index: 'not_analyzed'
      indexes :tag_ids, type: 'string', index: 'not_analyzed'
      indexes :tag_names, type: 'string', index: 'not_analyzed'
      indexes :uploader, type: 'string', index: 'not_analyzed'
      indexes :uploader_id, type: 'string', index: 'not_analyzed'
    end
  end
end
