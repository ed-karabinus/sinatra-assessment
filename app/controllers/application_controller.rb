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

  get '/users/:slug' do 
    if @user = User.find_by_slug(params[:slug])
      @categories = @user.categories
      @components = @user.components
      @title = "User #{@user.username}"
      erb :'users/show_user'
    else
      redirect to('/categories')
    end
  end

  get '/users/:slug/edit' do
    @user = user.find_by_slug(params[:slug])
    if is_logged_in? && @user == current_user
      erb :'users/edit_user'
    else
      redirect to('/categories')
    end
  end

  get '/signup' do
    if is_logged_in?
      redirect to('/categories')
    else
      @title = "Sign up"
      erb :'users/create_user'
    end
  end

  get '/login' do
    if is_logged_in?
      redirect to('/categories')
    else
      @title = "Log in"
      erb :'users/login'
    end
  end

  get '/logout' do
    if is_logged_in?
      session.clear
      redirect to('/login')
    else
      redirect to('/')
    end
  end

  post '/login' do 
    @user = User.find_by(username: params[:username])
    if @user.authenticate(params[:password])
      session[:id] = @user.id
      redirect to('/categories')
    else
      flash[:error] = "Invalid credentials. Please try again."
      redirect to('/login')
    end
  end

  post '/signup' do
    @user = User.new(username: params[:username], email: params[:email], password: params[:password])
    if @user.save
      session[:id] = @user.id
      redirect to('/categories')
    else
      errorArray = []
      @user.errors.messages.each do |key, value|
        value.each do |warning|
          errorArray << "#{key.capitalize} #{warning}. Please try again."
        end
      end
      flash[:error] = errorArray
      redirect to('/signup')
    end
  end

  helpers do
    def is_logged_in?
      !!session[:id]
    end

    def current_user
      User.find_by(id: session[:id])
    end
  end
  
end