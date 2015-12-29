class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user, only: [:edit, :update]
  #ensures only admin can delete users
  before_action :admin_user, only: :destroy
  
  #for will_paginate to work, the results must be paginated using the paginate 
  #method
  def index
    #paginate returns 30 users by default on a given page
    #will_paginate generates a page view using params[:page]
    @users = User.paginate(page: params[:page])
  end
  
  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
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
      # =WANT THEM TO ACTIVATE ACCOUNT FIRST
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
      #logs in a user after they make account
     # log_in(@user)
      # flash[:success] = "Welcome to Twitter Clone!"
      #redirect_to @user
    else
      render 'new'
    end
  end
  
  def edit
    #to edit the user first we have to pull the relevant user from the db
     #can eliminate assignment due to correct_user helper
    #@user = User.find(params[:id])
  end
  
  def update
    #can eliminate assignment due to correct_user helper
   # @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
      #Handle a successful update
    else
      #User model validations and error messages will bring up errors
      #and reroute to the edit page
      render 'edit'
    end
  end
  
  #delete request sends to the destroy action
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end
  
  private
    #initializes an appropriate new hash
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
    
    
    
    #make sure the user searched and being edited is the same user being logged in
    #(verified with a cookie or token)
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end
    
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end
