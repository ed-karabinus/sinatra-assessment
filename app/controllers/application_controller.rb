require './config/environment'

class ApplicationController < Sinatra::Base

  configure do 
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions
    set :session_secret, 'jamal'
    register Sinatra::Flash
  end

  get '/' do
    @title = "GearTracker"
    if is_logged_in?
      redirect to("/users/#{current_user.slug}")
    else
      erb :index
    end
  end

  helpers do
    def is_logged_in?
      !!session[:id]
    end

    def current_user
      @user ||= User.find_by(id: session[:id])
    end
  end
  
end