require 'test_helper'
require 'rack/test'

class ImagesControllerTest < ActionController::TestCase
  setup do
    @image = images(:zero)
  end

  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get show" do
    get :show, id: @image
    assert_response :success
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create image" do
    image_file = Rack::Test::UploadedFile.new(Rails.root.join('test','fixtures','image_files','water_drop.png'), "image/png")
    assert_difference('Image.count') do
      post :create, image: { description: @image.description, source_url: @image.source_url, tag_list: 'safe,water,simple background', image: image_file }
    end
    assert_redirected_to image_path(assigns(:image))
  end
end
