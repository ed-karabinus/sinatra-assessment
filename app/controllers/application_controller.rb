require './config/environment'

class ApplicationController < Sinatra::Base

  configure do 
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions
    set :session_secret, 'jamal'
  end

  get '/' do
    erb :index
  end

  get '/users/:slug' do 
    @user = User.find_by_slug(params[:slug])
    @categories = Category.all.find_all do |category|
      category.user_id == @user.id 
    end
    erb :'categories/categories'
  end

  get '/categories' do
    if is_logged_in?
      @categories = Category.all.find_all do |category|
        category.user_id == current_user.id
      end
      erb :'categories/categories'
    else
      redirect to('/login')
    end
  end

  get '/signup' do
    if is_logged_in?
      redirect to('/categories')
    else
      erb :'users/create_user'
    end
  end

  get '/login' do
    if is_logged_in?
      redirect to('/categories')
    else
      erb :'users/login'
    end
  end

  post '/login' do 
    @user = User.find_by(username: params[:username])
    if @user.authenticate(params[:password])
      session[:id] = @user.id
      redirect to('/categories')
    else
      redirect to('/login')
    end
  end

  post '/signup' do
    @user = User.new(username: params[:username], email: params[:email], password: params[:password])
    if @user.save
      session[:id] = @user.id
      redirect to('/categories')
    else
      redirect to('login')
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