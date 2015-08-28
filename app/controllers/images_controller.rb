class ImagesController < ApplicationController
  def index
    @images_search = Image.fancy_search(size: 25) do |search|
      search.add_sort :created_at, :desc
    end
    @images = @images_search.records
  end

  def show
    @image = Image.find_by(id_number: params[:id])
    render_404_if_not(@image) do
      render
    end
  end

  def tags
    @image = Image.find_by(id_number: params[:image_id])
    render_404_if_not(@image) do
      render partial: 'tags/tag_list', layout: false, locals: {tags: @image.tags.desc(:system).asc(:name)}
    end
  end

  def new
    @image = Image.new
  end

  def create
    @image = Image.new
    @image.ip = request.remote_ip
    @image.user_agent = request.env['HTTP_USER_AGENT']
    @image.user = current_user
    if @image.assign_attributes(params.require(:image).permit(Image::ALLOWED_PARAMETERS))
      @image.save!
      redirect_to image_path(@image)
    else
      render action: 'new'
    end
  end
end
