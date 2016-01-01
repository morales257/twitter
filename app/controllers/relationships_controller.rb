class RelationshipsController < ApplicationController
  before_action :logged_in_user
  
  def create
    #find the user using their user_id which is now stored in followed_id
    @user = User.find(params[:followed_id])
    #create the relationship using the follow function
    current_user.follow(@user)
    #in adding ajax to our follow and unfollow, we add the following js line
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
    end
  end
  
  def destroy
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow(@user)
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
    end
  end
end
