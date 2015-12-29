class StaticPagesController < ApplicationController
  
  def home
    #define @micropost using the curret_user to micropost association since
    #the current_user should only exist if the user is logged in
    if logged_in?
      @micropost = current_user.microposts.build 
      #this variable calls on the feed method to show all the users posts on
      #the home page
      @feed_items = current_user.feed.paginate(page: params[:page])
    end
  end

  def help
  end
  
  def about
  end
  
  def contact
  end
end
