class ImagesController < ApplicationController
  def index
    @images = Image.desc(:created_at)
  end

  def show
    @image = Image.find_by(id_number: params[:id])
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
    end
  end
end