require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  
  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end
  
  test "should get new" do
    get :new
    assert_response :success
  end
  
  #because before filters work in a per-action basis, we put them here in a 
  #controller test
  
  test "should redirect edit when not logged in" do
    #simulate get action
    get :edit, id: @user
    #make sure error message comes up
    assert_not flash.empty?
    assert_redirected_to login_url
  end
  
  test "should redirect update when not logged in" do
    #simulate patch action, user hash is needed for route to work properly
    patch :update, id: @user, user: { name: @user.name, email: @user.email }
    assert_not flash.empty?
    assert_redirected_to login_url
  end
  
  test "should redirect edit when logged in as wrong user" do
    log_in_as(@other_user)
    get :edit, id: @user
    #since there is no message for a user trying to edit another, make sure its empty
    assert flash.empty?
    assert_redirected_to root_url
  end
  
   test "should redirect update when logged in as wrong user" do
    log_in_as(@other_user)
    patch :update, id: @user, user: { name: @user.name, email: @user.email }
    assert flash.empty?
    assert_redirected_to root_url
  end
  
  test "should redirect index when not logged in" do
    get :index
    assert_redirected_to login_url
  end
  
  test "should redirect destroy when not logged in" do
    #make sure user count doesnt change
    assert_no_difference 'User.count' do
      #issue a DELETE request directly to the destroy action
      delete :destroy, id: @user
    end
    assert_redirected_to login_url
  end
  
  test "should redirect destroy when logged in as non-admin" do
    log_in_as(@other_user)
    #make sure user count doesnt change
    assert_no_difference 'User.count' do
      #issue a DELETE request directly to the destroy action
      delete :destroy, id: @user
    end
    assert_redirected_to root_url
  end
  
  
  test "should redirect following when not logged in" do
    get :following, id: @user
    assert_redirected_to login_url
  end
  
  test "should redirect followers when not logged in" do
    get :followers, id: @user
    assert_redirected_to login_url
  end
  
end
