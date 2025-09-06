require "test_helper"

class Public::ProfilesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get public_profiles_show_url
    assert_response :success
  end
end
