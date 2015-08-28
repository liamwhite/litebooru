module FancySearchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
  end

  class FancySearchableOptions
    attr_reader :queries
    attr_reader :filters
    attr_reader :sorts
    attr_accessor :size

    def initialize
      # Initialize with default match_all query, others unspecified
      @queries = [{match_all: {}}]
      @filters = []
      @sorts = []

      # Default size is 15 records
      @size = 15
    end

    def add_query(query, conj=:must)
      @queries.push({:bool => {conj => query} })
    end

    def add_filter(filter, conj=:must)
      @filters.push({:bool => {conj => filter} })
    end

    def add_sort(field, direction)
      @sorts.push({field => direction})
    end
  end

  class_methods do

    # Provides a default sort if none specified when querying.
    # Derived classes may override this.
    def default_sort
      []
    end

    # Main fancy_search function. Provides tire-like search API:
    #
    # response = Image.fancy_search(size: 25) do |search|
    #   search.add_filter term: {hidden_from_users: false, _cache: true}
    #   search.add_sort :created_at, :desc
    # end
    # @images = response.records
    #
    def fancy_search(options = {}, &block)
      searchable_options = FancySearchableOptions.new

      if options[:size]
        searchable_options.size = options[:size]
      end

      if block
        yield searchable_options
      end

      sorts = searchable_options.sorts
      if sorts.empty?
        sorts = self.default_sort
      end

      # Response is lazily evaluated.
      response = self.search query: {bool: {must: searchable_options.queries}},
                             filter: {bool: {must: searchable_options.filters}},
                             sort: sorts,
                             size: searchable_options.size
      return response
    end
  end
end
