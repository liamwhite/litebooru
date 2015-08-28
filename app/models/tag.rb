class Tag
  include Mongoid::Document
  include FancySearchable
  include Indexable
  include Sluggable

  # Fields
  field :description, type: String, default: ""
  field :image_count, type: Integer, default: 0
  field :name, type: String
  field :namespace, type: String
  field :name_in_namespace, type: String
  field :short_description, type: String, default: ""
  field :system, type: Boolean
  set_slugged_field :name

  # Relations
  belongs_to :aliased_tag, class_name: 'Tag', validate: false, inverse_of: :aliases
  has_many :aliases, inverse_of: :aliased_tag, class_name: 'Tag', validate: false
  has_and_belongs_to_many :implied_tags, inverse_of: :implied_by_tags, class_name: 'Tag', validate: false
  has_and_belongs_to_many :implied_by_tags, inverse_of: :implied_tags, class_name: 'Tag', validate: false

  # Indexes
  index({aliased_tag_id: 1})
  index({implied_tag_ids: 1}, {sparse: true})
  index({image_count: 1})
  index({name: 1})
  index({namespace: 1})
  index({system: 1}, {sparse: true})

  # Validations
  validates_presence_of :name
  validates :name, length: {maximum: 75}

  # Elasticsearch
  def as_json(options = {})
    d = {
      id: self.id.to_s,
      name: self.name,
      description: self.description,
      short_description: self.short_description,
      image_count: self.image_count,
      system: self.system,
    }
  end

  settings index: { number_of_shards: 1 } do
    mappings dynamic: 'false', _source: {enabled: false}, _all: {enabled: false} do
      indexes :id, type: 'string', index: 'not_analyzed'
      indexes :name, type: 'string', index: 'not_analyzed'
      indexes :image_count, type: 'integer', index: 'not_analyzed'
      indexes :description, type: 'string', analyzer: 'snowball'
      indexes :short_description, type: 'string', analyzer: 'snowball'
      indexes :system, type: 'boolean', index: 'not_analyzed'
    end
  end

  def set_image_count
    self.image_count = Image.in(tag_ids: [self.id]).where(hidden_from_users: false).count
  end

  def to_param
    slug
  end

  def self.tags_per_page
    250
  end

  def self.tag_string_to_tags(tag_string)
    Tag.parse_tag_list(tag_string).map{ |t| Tag.get_tag_by_name(t) }
  end

  def self.get_tag_by_name(tag_name, create_if_missing=true)
    tag_name = Tag.clean_tag_name(tag_name)
    tag = Tag.find_by(name: tag_name)
    tag = Tag.create!(name: tag_name) if !tag and create_if_missing
    tag
  end

  def self.clean_tag_name(name)
    # lowercase only
    name.downcase!
    # replace_underscores
    name.gsub!('_','') unless name.include?('artist:')
    # collapse multiple spaces into one space to avoid people   using   many   spaces
    name.gsub!(/[\ ]{2,}/, '')
    # remove trailing spaces
    name.gsub!(/[\ ]\z/, '')
    name
  end

  private
  def self.parse_tag_list(tag_string)
    input_tags = []
    for tag in tag_string.split(",").map(&:strip)
      next if tag.blank?
      tag_name = Tag.clean_tag_name(tag)
      input_tags << tag_name
    end
    input_tags
  end

end
