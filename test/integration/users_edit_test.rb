require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end
  
  test "unsuccessful edit" do
    #add log in now that we have updated the update function
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), user: {
      name: "",
      email: "foo@invalid",
      password: "foo",
      password_confirmation:"bar" }
  
  assert_template 'users/edit'
  end
  
  test "successful edit" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    name = "Foo Bar"
    email = "foo@bar.com"
    #have to allow for empty passwords
    patch user_path(@user), user: {
      name: name,
      email: email,
      password: "",
      password_confirmation: ""
    }
    #make sure some message comes up after udpate
    assert_not flash.empty?
    assert_redirected_to @user
    #reloads the users values fromthe database to confirm that they were updated
    @user.reload
    assert_equal name, @user.name
    assert_equal email, @user.email 
  end
  
  test "make sure location is being saved" do
    get edit_user_path(@user)
    assert_not_nil session['forwarding_url']
  end
  
  test "successful edit with friendly forwarding" do
    get edit_user_path(@user)
    log_in_as(@user)
    assert_redirected_to edit_user_path(@user)
    name  = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), user: { name:  name,
                                    email: email,
                                    password:              "",
                                    password_confirmation: "" }
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name,  @user.name
    assert_equal email, @user.email
    
  end
  

end
