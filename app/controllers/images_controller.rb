class ImagesController < ApplicationController
  def index
    @images_search = Image.fancy_search(default_image_filter_options.merge(size: 25)) do |search|
      search.add_sort :created_at, :desc
    end
    @images = @images_search.records
  end

  def show
    @image = Image.find_by(id_number: params[:id])
    render_404_if_not(@image) do
      @comments = @image.comments.order(created_at: :desc).limit(25)
      render layout: 'image'
    end
  end

  def comments
    @image = Image.find_by(id_number: params[:id])
    @comments = @image.comments.order(created_at: :desc).limit(25)
  end

  def update_metadata
    @image = Image.find_by(id_number: params[:image_id])
    render_404_if_not(@image) do
      @image.set_tag_list(params[:tag_list])
      render partial: 'images/tags_source', layout: false
    end
  end

  def new
    @image = Image.new
  end

  def create
    @image = Image.new(params.require(:image).permit(Image::ALLOWED_PARAMETERS))
    @image.capture!(current_user, request)
    if @image.save
      redirect_to image_path(@image)
    else
      render action: 'new'
    end
  end
end
