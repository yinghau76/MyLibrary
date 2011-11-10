# Filters added to this controller will be run for all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
class ApplicationController < ActionController::Base
  
  private
  
  # a filter to authorize user
  def authorize
    @user = User.find_by_id(session[:user_id])
    unless @user
      # remember original URI that will be redirected to after successful login.
      session[:original_uri] = request.request_uri
      redirect_to :controller => "login", :action => "login"
    end
  end
  
  # a filter to check admin...  
  def check_admin
    unless @user.name == 'patrick'
      flash[:notice] = "Admin required!"
      session[:original_uri] = request.request_uri
      redirect_to :controller => "login", :action => "login"
    end
  end     
    
end