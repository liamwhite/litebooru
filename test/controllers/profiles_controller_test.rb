require 'test_helper'

class ProfilesControllerTest < ActionController::TestCase
  setup do
    @user = users(:administrator)
  end

  test "should get show" do
    get :show, id: @user
    assert_response :success
  end
end
