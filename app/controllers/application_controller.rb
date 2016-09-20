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

    def createErrorArray(model) 
      errorArray = []
      model.errors.messages.each do |key, value|
        value.each do |warning|
          errorArray << "#{key.capitalize} #{warning}. Please try again."
        end
      end
      errorArray
    end

    def populateFlashHash(model, attributes)
      attributes.each do |attribute|
        unless model.errors.messages.has_key?(attribute)
          flash.[]=(attribute, params[attribute])
        end
      end
    end
  end
  
end