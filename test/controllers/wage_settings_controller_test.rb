require 'test_helper'

class WageSettingsControllerTest < ActionDispatch::IntegrationTest
  test "should get edit" do
    get wage_settings_edit_url
    assert_response :success
  end

  test "should get update" do
    get wage_settings_update_url
    assert_response :success
  end

end
