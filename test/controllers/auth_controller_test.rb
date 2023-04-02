require 'test_helper'

class AuthControllerTest < ActionDispatch::IntegrationTest
  test "should get google_oauth2_callback" do
    get auth_google_oauth2_callback_url
    assert_response :success
  end

end
