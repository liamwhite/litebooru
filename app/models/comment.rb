class Comment
  include Mongoid::Document
  include Mongoid::Timestamps
  include AnonymizableUserAttributable
  include FancySearchable
  include Indexable

  # Fields
  field :body, type: String, default: ''
  field :hidden_from_users, type: Boolean, default: false
  field :deleted_at, type: Time, default: nil

  # Relations
  belongs_to :user, validate: false
  belongs_to :image, index: true, validate: false
  belongs_to :deleted_by, class_name: "User"

  # Indexes
  index image_id: 1, created_at: -1
  index created_at: 1

  # Validations
  validates_presence_of :body

  ALLOWED_PARAMETERS = [:body, :anonymous]

  # Callbacks
  after_create do |c|
    c.image.set(updated_at: Time.now)
    c.image.inc(comment_count: 1)
  end

  before_destroy do |c|
    c.image.set(updated_at: Time.now)
    c.image.inc(comment_count: -1)
  end

  # Elasticsearch
  def as_json(options = {})
    d = {
      id: self.id.to_s,
      image_id: self.image_id.to_s,
      body: (self.hidden_from_users ? '(deleted)' : self.body),
      author: self.author.try(:name).to_s,
      created_at: self.created_at,
      updated_at: self.updated_at,
      hidden_from_users: self.hidden_from_users,
    }
  end

  def as_indexed_json(options = {})
    d = as_json(options)
    d[:body] = self.body.to_s
    d[:user_id] = self.user_id.to_s
    d[:ip] = self.ip
    d
  end

  settings index: { number_of_shards: 1 } do
    mappings dynamic: 'false', _all: {enabled: false}, _source: {enabled: false} do
      indexes :id, type: 'string', index: 'not_analyzed'
      indexes :image_id, type: 'string', index: 'not_analyzed'
      indexes :body, type: 'string', analyzer: 'snowball'
      indexes :author, type: 'string', index: 'not_analyzed'
      indexes :created_at, type: 'date'
      indexes :updated_at, type: 'date'
      indexes :hidden_from_users, type: 'boolean', index: 'not_analyzed'
      indexes :user_id, type: 'string', index: 'not_analyzed'
      indexes :ip, type: 'string', index: 'not_analyzed'
    end
  end

  def self.default_sort
    [{:created_at => :desc}]
  end

  def self.default_field
    :body
  end

  def self.allowed_fields(options = {})
    [:id, :image_id, :body, :author]
  end


  def hide!
    self.hidden_from_users = true
    self.close_open_reports!
    self.save!
  end

  def unhide!
    self.hidden_from_users = false
    self.save!
  end

end
