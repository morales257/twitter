require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  
  def setup 
    @user = User.new(name: "Example User", email: "example@example.com", password: "foobar", password_confirmation: "foobar")
  end
  
  test "should be valid" do
    assert @user.valid?
  end
  
  test "should be present" do
    @user.name = "   "
    #we wanted to assert that its not true, but it was true
    #by adding presence: true to validates method, we now have validation
    assert_not @user.valid?
  end
  
  test "email shoud be present" do
    @user.email = " "
    assert_not @user.valid?
  end
  
  test "name should not be too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end
  
  test "email should not be too long" do
    @user.email = "a" *244 + '@example.com'
    assert_not @user.valid?
  end
  
  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.com A_US-ER@foo.bar.org first.last@foo.jp]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      #optional message tells us which one is invalid
      assert @user.valid? "#{valid_address.inspect} should be valid"
    end
  end
  
  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end
  
  test "email addresses should be unique" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    #for uniqueness test we actually have to put a record in the db
    @user.save
    assert_not duplicate_user.valid?
  end
  
  test "password should be present(nonblank)" do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end

  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = 'a' * 5
    assert_not @user.valid?
  end
  
  #scenario with 2 different browsers, starting with a user with no remember digest
   test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, '')
  end
  
  test "associated microposts should be destroyed" do
    #saving the user creates an id
    @user.save
    @user.microposts.create!(content: "Lorem ipsum")
    #make sure dependent option works by seeing if post count goes down 
    #after deleting the user associated with the micropost above
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end
  
  
  #adding has_many :through association to the user model gives us the ability
  #to introduce utility methods like follow and unfollow to add a social component
  #to our site
  test "shoud follow and unfollow a user" do
    michael = users(:michael)
    archer = users(:archer)
    assert_not michael.following?(archer)
    michael.follow(archer)
    assert michael.following?(archer)
    #this looks for michaels follower_id assoc with archer's followed_id
    assert archer.followers.include?(michael)
    michael.unfollow(archer)
    assert_not michael.following?(archer)
  end
  
  test "feed should have the right posts" do
    michael = users(:michael)
    archer  = users(:archer)
    lana    = users(:lana)
    #Posts from a followed user
    lana.microposts.each do |post_following|
      assert michael.feed.include?(post_following)
    end
    #Posts from self
    michael.microposts.each do |post_self|
      assert michael.feed.include?(post_self)
    end
    #Posts from an unfollowed user
    archer.microposts.each do |posts_unfollowed|
      assert_not michael.feed.include?(posts_unfollowed)
    end
  end
end
