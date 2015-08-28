class TagsController < ApplicationController
  def index
    @tags_search = Tag.fancy_search do |search|
      search.add_sort :image_count, :desc
      search.add_sort :name, :asc
    end
    @tags = @tags_search.page(params[:page]).per(Tag.tags_per_page).records
  end

  def show
    @tag = Tag.find_by(slug: params[:id])
    render_404_if_not(@tag) do
      @images_search = Image.fancy_search(size: 25) do |search|
        search.add_filter term: {tag_ids: @tag.id.to_s}
      end
      @images = @images_search.records
      render
    end
  end
end
