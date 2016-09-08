require './config/environment'

class CategoriesController < ApplicationController
  get '/categories/new' do 
    if is_logged_in?
      erb :'categories/create_category'
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

  post '/categories' do
    @category = Category.new(name: params[:name], description: params[:description], user_id: session[:id])
    if @category.save
      redirect to("/categories/#{@category.id}")
    else
      redirect to('/categories/new')
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
end