module SessionsHelper
  
  #login a given user
  def log_in(user)
    #session places temp cookie of an encrypted version of the user id in the browser
    #and allows us to retrieve it on subsequent pages using session[:user_id]
    #tem cookie expires when browser is closed
    session[:user_id] = user.id
  end
  
  def remember(user)
    #creates a new remember token and saves its digest to the database
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end
  
  #Return the user corresponding to the remember token cookie
  def current_user
    #store the results in an instance variable so we dont have to visit the 
    #database every time a user is on a page
    #retrieve the user from a temporary session if session[:user_id] exists
    if(user_id= session[:user_id])
     @current_user ||= User.find_by(id: user_id)
     #otherwise look for cookies[:user_id] to retrieve and log in the user
     #corresponding to the persistent session
    elsif(user_id = cookies.signed[:user_id])
      user = User.find_by(id: cookies.signed[:user_id])
        if user && user.authenticated?(cookies[:remember_token])
          log_in user
          @current_user = user
        end
      end
  end
  
  #returns true if user is logged in
  def logged_in?
    !current_user.nil?
  end
  
  #forget persistent session
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end
  #log out the current user
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end
end
