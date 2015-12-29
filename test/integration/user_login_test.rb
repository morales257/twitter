require 'test_helper'

class UserLoginTest < ActionDispatch::IntegrationTest
    def setup
    #users is the fixture and :michael is the user we set up to test
    @user = users(:michael)
    end
  
  test "login with invalid user information" do
    get login_path
    assert_template 'sessions/new'
    post login_path, session: { email: "", password: "" }
    assert_template 'sessions/new'
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end
  
  test "login with valid information followed by login out" do
    get login_path
    post login_path, session: { email: @user.email, password: 'password' }
    assert is_logged_in?
    assert_redirected_to @user
    #follow_redirect visits the target page
    follow_redirect!
    #there, it makes sure the following is showing
    assert_template 'users/show'
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
    #test to make sure session deletes and links change with log out
    delete logout_path
    #make sure session is deleted
    assert_not is_logged_in?
    assert_redirected_to root_url
    #Simulate a user clicking logout in a second window
    #shoould fail due to current user being nil
    delete logout_path
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path, count: 0
    assert_select "a[href=?]", user_path(@user), count:0
  end
  
  test "login with remembering" do
    #use the user we made in the fixture and defined above in setup
    log_in_as(@user, remember_me: '1')
    #test to see that the user has a remember token
    assert_not_nil cookies['remember_token']
  end
  
  test "login without remembering" do
    #use the user we made in the fixture and defined above in setup
    log_in_as(@user, remember_me: '0')
    assert_nil cookies['remember_token']
  end
  
end
