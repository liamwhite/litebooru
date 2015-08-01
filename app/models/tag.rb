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
end
