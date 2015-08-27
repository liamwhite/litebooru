require 'elasticsearch/model'

# Patch in Kaminari
Kaminari::Hooks.init
Elasticsearch::Model::Response::Response.__send__(
  :include, Elasticsearch::Model::Response::Pagination::Kaminari
)
Elasticsearch::Model::Response::Records.__send__(
  :include, Elasticsearch::Model::Response::Pagination::Kaminari
)

# Ordering hack, requires Kaminari support to be patched in
Elasticsearch::Model::Adapter::Mongoid::Records.class_eval do
  def records
    klass.where(:id.in => ids).instance_exec(response.response['hits']['hits']) do |hits|
      self.entries.sort_by { |e| hits.index { |hit| hit['_id'].to_s == e.id.to_s } }
    end
  end
end

module Indexable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model

    # Callbacks to ensure that documents are automatically indexed
    after_create do
      self.__elasticsearch__.index_document
    end
    after_destroy do
      self.__elasticsearch__.delete_document
    end
  end

  def update_index
    if (self.class.mappings.options[:_source][:enabled] rescue true)
      # Is _source enabled? (It is by default.)
      self.__elasticsearch__.update_document
    else
      self.__elasticsearch__.index_document
    end
  end

end
