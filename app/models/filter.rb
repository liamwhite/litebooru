class Filter < ActiveRecord::Base
  include FancySearchable
  include Indexable
  include QueryValidatable

  # Relations
  belongs_to :user, inverse_of: :filters
  has_many :current_users, inverse_of: :current_filter

  validates_query_string :hidden_complex
  validates_query_string :spoilered_complex

  def as_json(options = {})
    d = {
      id: self.id,
      created_at: self.created_at,
      updated_at: self.updated_at,
      name: self.name,
      description: self.description,
      system: self.system,
      public: self.public,
      user_count: self.user_count,
      user_id: self.user_id.to_s
    }
  end

  alias as_indexed_json as_json

  settings index: { number_of_shards: 1 } do
    mappings dynamic: 'false', _source: {enabled: false}, _all: {enabled: false} do
      indexes :id, index: :not_analyzed, type: 'integer'
      indexes :created_at, type: 'date'
      indexes :updated_at, type: 'date'
      indexes :name, type: 'string', analyzer: 'snowball'
      indexes :description, type: 'string', index: 'not_analyzed'
      indexes :system, type: 'boolean', index: 'not_analyzed'
      indexes :public, type: 'boolean', index: 'not_analyzed'
      indexes :user_count, type: 'integer', index: 'not_analyzed'
      indexes :user_id, type: 'integer', index: 'not_analyzed'
    end
  end

  def self.default_filter
    return @@default_filter if defined?(@@default_filter)
    @@default_filter = Filter.find_by(name: 'Default', system: true, public: true)
    @@default_filter = Filter.create(name: 'Default', system: true, public: true) if not @@default_filter
  end
end
