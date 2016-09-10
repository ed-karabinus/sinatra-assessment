require './config/environment'

class CategoriesController < ApplicationController
  get '/categories/new' do 
    if is_logged_in?
      @title = "Create category"
      erb :'categories/create_category'
    else
      redirect to('/login')
    end
  end

  get '/categories/:id' do
    if is_logged_in? && @category = Category.find_by(id: params[:id])
      @title = "#{@category.name}"
      erb :'categories/show_category'
    elsif is_logged_in?
      redirect to('/categories')
    else
      redirect to('/login')
    end
  end

  get '/categories/:id/edit' do 
    if is_logged_in? && @category = Category.find_by(id: params[:id])
      @category = Category.find_by(id: params[:id])
      @title = "Edit #{@category.name}"
      erb :'categories/edit_category'
    elsif is_logged_in?
      redirect to('/categories')
    else
      redirect to('/login')
    end
  end

  get '/categories' do
    if is_logged_in?
      @categories = Category.all.find_all do |category|
        category.user_id == current_user.id
      end
      @title = "Your categories"
      erb :'categories/categories'
    else
      redirect to('/login')
    end
  end

  post '/categories' do
    @category = Category.new(name: params[:name], description: params[:description], user_id: session[:id])
    if is_logged_in? && @category.save
      redirect to("/categories/#{@category.id}")
    else
      redirect to('/categories/new')
    end
  end

  patch '/categories/:id/edit' do
    @category = Category.find_by(id: params[:id])
    if is_logged_in? && @category.user_id == session[:id] && @category.update(name: params[:name], description: params[:description])
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