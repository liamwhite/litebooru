class TagsController < ApplicationController
  def index
    @tags = Tag.search(query: {match_all: {}}, sort: [{image_count: :desc}, {name: :asc}], size: 20).page(params[:page]).per(Tag.tags_per_page).records
  end

  def show
    @tag = Tag.find_by(slug: params[:id])
    if @tag
      @images = Image.search(query: {match_all: {}}, filter: {term: {tag_ids: @tag.id.to_s}}, sort: {created_at: :desc}).records
      render 'images/index'
    else
      render 'pages/render_404'
    end
  end
end
