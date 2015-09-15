require 'test_helper'

class CommentsControllerTest < ActionController::TestCase
  setup do
    @image = images(:zero)
    @comment = Comment.create!(anonymous: false, body: 'foo', image: @image)
  end

  test "should create comment" do
    assert_difference('Comment.count') do
      post :create, comment: { body: @comment.body }, image_id: @image
    end

    assert_redirected_to image_path(@image)
  end

  test "should show comment" do
    get :show, id: @comment, image_id: @image
    assert_response :success
  end

  test "should destroy comment" do
    assert_difference('Comment.count', -1) do
      delete :destroy, id: @comment, image_id: @image
    end

    assert_redirected_to image_path(@image)
  end
end
