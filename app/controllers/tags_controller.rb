class TagsController < ApplicationController
  def index
    @tags = Tag.search(query: {match_all: {}}, sort: [{image_count: :desc}, {name: :asc}], size: 20).records
  end

  def show
  end
end
