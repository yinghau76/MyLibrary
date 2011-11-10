class LoginController < ApplicationController

  layout "login"
  before_filter :authorize, :except => :login
  
  def add_user
    @user = User.new(params[:user])
    if request.post? and @user.save
      flash.now[:notice] = "User #{@user.name} created"
      
      # Let the admin continue entering more users
      @user = User.new
    end
  end

  def login
    session[:user_id] = nil
    if request.post?
      user = User.authenticate(params[:name], params[:password])
      if user
        session[:user_id] = user.id
        uri = session[:original_uri]
        session[:original_uri] = nil
        redirect_to(uri || {:action => "index"})
      else
        flash[:notice] = "Invalid user/password combination"
      end
    end    
  end

  def logout
    session[:user_id] = nil
    flash[:notice] = "Logged out"
    redirect_to :action => "login"
  end

  def index
    redirect_to :controller => "admin", :action => "index"
  end

  def delete_user
    if request.post?
      user = User.find(params[:id])
      user.destroy
    end
    redirect_to(:action => :list_users)
  end

  def list_users
    @all_users = User.find(:all)
  end
end
