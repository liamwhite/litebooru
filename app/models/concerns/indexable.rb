require 'elasticsearch/model'

# Patch in Kaminari
Kaminari::Hooks.init
Elasticsearch::Model::Response::Response.__send__(
  :include, Elasticsearch::Model::Response::Pagination::Kaminari
)
Elasticsearch::Model::Response::Records.__send__(
  :include, Elasticsearch::Model::Response::Pagination::Kaminari
)

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
