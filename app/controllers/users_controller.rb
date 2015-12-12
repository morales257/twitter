class UsersController < ApplicationController
  
  def show
    @user = User.find(params[:id])
    #debugger
  end
  #sign up page routes to new
  def new
    @user = User.new
  end
  
  #when you push the create account
  def create
    #to avoid unwanted/unsafe requests we replace params[:user]
    @user = User.new(user_params)
    if @user.save
      #logs in a user after they make account
      log_in(@user)
       flash[:success] = "Welcome to Twitter Clone!"
      redirect_to @user
    else
      render 'new'
    end
  end
  
  private
    #initializes an appropriate new hash
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
end
