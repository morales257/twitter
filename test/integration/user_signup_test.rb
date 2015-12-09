require 'test_helper'

class UserSignupTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
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
  
  test "valid signup information" do
    get signup_path
    
    assert_difference "User.count", 1 do
      #arranges to redirect after submission with post_via_redirect
    post_via_redirect users_path, user: { name: "Example",
                            email: "luis@example.com",
                            password: "foobar",
                            password_confirmation: "foobar" }
    end
    assert_template 'users/show'
  end
end
