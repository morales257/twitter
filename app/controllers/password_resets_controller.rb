class PasswordResetsController < ApplicationController
  before_action :get_user, only: [:edit, :update]
  before_action :valid_user, only:[:edit, :update]
  #make sure the link to reset has not expired
  before_action :check_expiration, only: [:edit, :update]
  
  #clicking forgot passwords routes to new, which bring up the new "forgot password page"
  def new
  end

#clicking submit sends the email to the user, which entails looking for the user
#making a reset token and sending the user the email
  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      #send_password_reset_email calls the password_rest function in the mailer
      #which sends an to the user
      @user.send_password_reset_email
      flash[:info] = "Email sent with password reset instructions"
      redirect_to root_url
    else
      flash.now[:danger] = "Email address not found"
      render 'new'
    end
      
  end
  
  def edit
  end
  
  #what happens when you submit new password
  def update
    #if password is empty...
    if params[:user][:password].empty?
      @user.errors.add(:password, "can't be empty")
      render 'edit'
      #if update is successful...
    elsif @user.update_attributes(user_params)
      log_in @user
      flash[:success] = "Password has been reset."
      redirect_to @user
    else
      #if there is an error...
      render 'edit'
    end
    
  end
  
  private
  
  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end
  
  #fetch the user trying to reset the password
  def get_user
    @user = User.find_by(email: params[:email])
  end
  
  #Confirm a valid user
  def valid_user
    #in this case params[:id] holds the reset token
    unless(@user && @user.activated? && @user.authenticated?(:reset, params[:id]))
    redirect_to root_url
    end
  end
  
  def check_expiration
    if @user.password_reset_expired?
      flash[:danger] = "Password reset has expired."
      #redirect them to resend themselves an email to reset
      redirect_to new_password_reset_url
    end
  end
  
end
