class SessionsController < ApplicationController
  def new
  end
  
  def create
    user = User.find_by(email: params[:session][:email].downcase)
    
    if user && user.authenticate(params[:session][:password])
      log_in user
      #this is a helper, not a user class method
      #this line adds checkbox functionality
      params[:session][:remember_me] == '1' ? remember(user) : forget(user)
      #rails auto converts this to route to the users profile page - user_url(user)
      redirect_to user
    else
      #this produces a bug so we should fix it with a test
      # using flash.now ensures the message appears on rendered pages
      #and disappears with another request
      flash.now[:danger] = "Invalid email/password combination"
    render 'new'
    end
  end
  
  def destroy
    #from the Sessions module
    #this if will solve our problem of having 2 browsers open
    log_out if logged_in?
    redirect_to root_url
  end
end
