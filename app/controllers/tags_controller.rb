class TagsController < ApplicationController
  def index
    @tags = Tag.search(query: {match_all: {}}, sort: [{image_count: :desc}, {name: :asc}], size: 20).page(params[:page]).per(Tag.tags_per_page).records
  end

  def show
  end
end
