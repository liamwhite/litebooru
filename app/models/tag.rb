class Tag
  include Mongoid::Document

  # Fields
  field :description, type: String, default: ""
  field :image_count, type: Integer, default: 0
  field :name, type: String
  field :namespace, type: String
  field :name_in_namespace, type: String
  field :short_description, type: String, default: ""
  field :system, type: Boolean

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
