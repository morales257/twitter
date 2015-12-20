require 'test_helper'

class UserSignupTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  
  def setup
    ActionMailer::Base.deliveries.clear
  end
  
  test "invalid signup information" do
  get signup_path
  #make sure there is no difference before and after making a new user
    assert_no_difference "User.count" do
    #to test form submission we need to create a post request
    #here we are including the params([:user]) hash passed to create 
      post users_path, user: { name: "",
                            email: "luis@invalid",
                            password: "foo",
                            password_confirmation: "bar" }
    end
  assert_template 'users/new'
  end
  
  test "valid signup information with account activation" do
    get signup_path
    
    assert_difference "User.count", 1 do
      #arranges to redirect after submission with post_via_redirect
    #post_via_redirect users_path, user: { name: "Example",
    post users_path, user: {name: "Example User",
                            email: "user@example.com",
                            password: "foobar",
                            password_confirmation: "foobar" }
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
    #assign allows us to access instance variables in the corresponding action
    user = assigns(:user)
    assert_not user.activated?
    #Try to log in before activation
    log_in_as(user)
    assert_not is_logged_in?
     # Invalid activation token
    get edit_account_activation_path("invalid token")
    assert_not is_logged_in?
    # Valid token, wrong email
    get edit_account_activation_path(user.activation_token, email: 'wrong')
    assert_not is_logged_in?
    # Valid activation token
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    follow_redirect!
    assert_template 'users/show'
    #use a test helper function
    assert is_logged_in?
    
  end
  
  
  
end
