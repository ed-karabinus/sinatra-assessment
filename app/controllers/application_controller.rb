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

  get '/categories/new' do 
    if is_logged_in?
      erb :'categories/create_category'
    else
      redirect to('/login')
    end
  end

  get '/components/new' do 
    if is_logged_in?
      erb :'components/create_component'
    else
      redirect to('/login')
    end
  end

  get '/categories/:id' do
    if is_logged_in?
      @category = Category.find_by(id: params[:id])
      @user = User.find_by(id: @category.user_id)
      erb :'categories/show_category'
    else
      redirect to('/login')
    end
  end

  get '/components/:id' do
    if is_logged_in?
      @component = Component.find_by(id: params[:id])
      @category = Category.find_by(id: @component.category_id)
      @user = User.find_by(id: @category.user_id)
      erb :'components/show_component'
    else
      redirect to('/login')
    end
  end

  get '/categories/:id/edit' do 
    if is_logged_in?
      @category = Category.find_by(id: params[:id])
      erb :'categories/edit_category'
    else
      redirect to('/login')
    end
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

  get '/components' do
    if is_logged_in?
      @components = Component.all.find_all do |component|
        Category.find_by(id: component.category_id).user_id == current_user.id 
      end
      erb :'components/components'
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
      redirect to('/login')
    end
  end

  post '/categories' do
    @category = Category.new(name: params[:name], description: params[:description], user_id: session[:id])
    if @category.save
      redirect to("/categories/#{@category.id}")
    else
      redirect to('/categories/new')
    end
  end

  post '/components' do
    @component = Component.new(name: params[:name], description: params[:description], category_id: params[:category_id])
    if @component.save
      redirect to("/components/#{@component.id}")
    else
      redirect to('/components/new')
    end
  end

  post '/signup' do
    @user = User.new(username: params[:username], email: params[:email], password: params[:password])
    if @user.save
      session[:id] = @user.id
      redirect to('/categories')
    else
      redirect to('/signup')
    end
  end

  patch '/categories/:id/edit' do
    @category = Category.find_by(id: params[:id])
    if @category.update(name: params[:name], description: params[:description])
      redirect to("/categories/#{params[:id]}")
    else
      redirect to("/categories/#{params[:id]}/edit")
    end
  end

  delete '/categories/:id/delete' do
    @category = Category.find_by(id: params[:id])
    if is_logged_in? && @category.user_id == session[:id]
      @category.destroy
      redirect to('/categories')
    else
      redirect to("/categories/#{params[:id]}")
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