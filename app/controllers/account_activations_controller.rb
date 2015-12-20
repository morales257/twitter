class AccountActivationsController < ApplicationController
  
  def edit
    #find user by email which is in the link 
    user = User.find_by(email: params[:email])
    #if the user exists, has not yet been activated, and activation digest and
    #token match...
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      #...then update the activation attribute in the db...
      user.activate
      #..and log in the user
      log_in user
      flash[:success] = "Account activated!"
      redirect_to user
    else
      flash[:danger] = "Invalid activation link"
      redirect_to root_url
    end
    
  end
end