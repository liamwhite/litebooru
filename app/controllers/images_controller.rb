class ImagesController < ApplicationController
  def index
    @images = Image.search(query: {match_all: {}}, sort: {created_at: :desc}).records
  end

  def show
    @image = Image.find_by(id_number: params[:id])
    if @image
      render
    else
      render 'pages/render_404'
    end
  end

  def new
    @image = Image.new
  end

  def create
    @image = Image.new
    @image.ip = request.remote_ip
    @image.user_agent = request.env['HTTP_USER_AGENT']
    if @image.assign_attributes(params.require(:image).permit(Image::ALLOWED_PARAMETERS))
      @image.save!
      redirect_to image_path(@image)
    else
      render action: 'new'
    end
  end
end
