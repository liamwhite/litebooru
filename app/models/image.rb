class Image < ActiveRecord::Base
  include AnonymizableUserAttributable
  include FancySearchable
  include Indexable
  include Notifyable
  include Reportable

  has_attached_file :image, presence: true, styles: {thumb_tiny: '50x50>', thumb_small: '150x150>', thumb: '250x250>', small: '320x240>', medium: '800x600>', large: '1280x1024>', tall: '1024x4096>'}

  # Validations
  validates_attachment :image, content_type: {content_type: %w|image/png image/jpeg image/gif|}, size: {in: 0..25000.kilobytes}, presence: true
  validates :id_number, uniqueness: true, presence: true

  ALLOWED_PARAMETERS = [:description, :image, :source_url, :tag_list]

  # Relations
  has_many :comments, validate: false
  belongs_to :user, inverse_of: :images
  belongs_to :hidden_by_user, class_name: 'User', inverse_of: :hidden_images

  # Callbacks
  before_validation do
    if not self.persisted?
      last_image = Image.order(id_number: :desc).select(:id_number).first
      if last_image and last_image.id_number and last_image.id_number >= 0
        self.id_number = last_image.id_number+1
      else
        self.id_number = 0
      end
    end
  end

  def to_param
    id_number.to_s
  end

  def tag_list=(tag_list)
    set_tag_list(tag_list)
  end

  def tag_list
    @tag_list ||= self.tags.map(&:name).join(',')
  end

  def set_tag_list(new_tag_list)
    old_tags = self.tags.to_a
    new_tags = Tag.tag_string_to_tags(new_tag_list)

    # Any tags we didn't previously have
    (new_tags - old_tags).each do |t|
      t.decrement!(:image_count)
      t.update_index
    end

    # Tags that were removed
    (old_tags - new_tags).each do |t|
      t.decrement!(:image_count)
      t.update_index
    end

    self.tag_ids = new_tags.map(&:id)
    @tag_list = new_tags.map(&:name).join(',')
  end

  def tags
    Tag.where(id: self.tag_ids)
  end

  # Elasticsearch
  def as_json(options = {})
    d = {
      id: self.id.to_s,
      id_number: self.id_number,
      created_at: self.created_at,
      updated_at: self.updated_at,
      description: self.description,
      hidden_from_users: self.hidden_from_users,
      comment_count: self.comment_count,
      source_url: self.source_url,
      tag_ids: self.tags.map{|t| t.id.to_s},
      tag_names: self.tags.map(&:name),
      uploader: self.author.try(:name).to_s,
    }
  end

  def as_indexed_json(options = {})
    d = self.as_json(options)
    d[:ip] = self.ip.to_s
    d[:uploader_id] = self.user_id.to_s
    return d
  end

  settings index: { number_of_shards: 1 } do
    mappings dynamic: 'false', _all: {enabled: false} do
      indexes :id, type: 'integer', index: 'not_analyzed'
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
      indexes :uploader_id, type: 'integer', index: 'not_analyzed'
    end
  end

  def self.default_sort
    [{:created_at => :desc}]
  end

  def self.default_field
    :tag_names
  end

  def self.allowed_fields(options = {})
    [:id, :id_number, :description, :source_url, :tag_names, :uploader]
  end

  def self.fancy_search(options = {}, &block)
    super(options) do |s|
      yield s if block

      # Filter hidden tags
      if not options[:hidden_tag_ids].blank?
        s.add_filter(not: {terms: {tag_ids: options[:hidden_tag_ids], _cache: true}})
      end

      # Hidden complex
      if not options[:hidden_complex].blank?
        parser = Image.get_search_parser.call(options[:hidden_complex], options)
        if parser.requires_query
          s.add_filter(fquery: {query: {bool: {must_not: parser.parsed}, _cache: true}})
        else
          s.add_filter(not: parser.parsed.merge(_cache: true))
        end
      end
    end
  end
end
