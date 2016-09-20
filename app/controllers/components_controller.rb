require './config/environment'

class ComponentsController < ApplicationController
  get '/components/new' do 
    if is_logged_in?
      @title = "Create component"
      @categories = current_user.categories
      erb :'components/create_component'
    else
      redirect to('/login')
    end
  end

  get '/components/:id' do
    if is_logged_in? && @component = Component.find_by(id: params[:id])
      @title = "#{@component.name}"
      erb :'components/show_component'
    elsif is_logged_in?
      redirect to('/components')
    else
      redirect to('/login')
    end
  end

  get '/components/:id/edit' do 
    if is_logged_in? && @component = Component.find_by(id: params[:id])
      @title = "Edit #{@component.name}"
      @categories = current_user.categories
      erb :'components/edit_component'
    elsif is_logged_in?
      redirect to('/components/:id')
    else
      redirect to('/login')
    end
  end

  get '/components' do
    if is_logged_in?
      @components = current_user.components
      @title = "Your components"
      erb :'components/components'
    else
      redirect to('/login')
    end
  end

  post '/components' do
    @component = Component.new(name: params[:name], description: params[:description], category_id: params[:category_id])
    if is_logged_in? && @component.save
      redirect to("/components/#{@component.id}")
    else
      flash[:error] = createErrorArray(@component)
      populateFlashHash(@component, [:name, :description, :category_id])
      redirect to('/components/new')
    end
  end

  patch '/components/:id/edit' do
    @component = Component.find_by(id: params[:id])
    if is_logged_in? && @component.category.user_id == session[:id] && @component.update(name: params[:name], description: params[:description], category_id: params[:category_id])
      redirect to("/components/#{params[:id]}")
    else
      flash[:error] = createErrorArray(@component)
      redirect to("/components/#{params[:id]}/edit")
    end
  end

  delete '/components/:id/delete' do
    @component = Component.find_by(id: params[:id])
    if is_logged_in? && @component.category.user_id == session[:id]
      @component.destroy
      redirect to('/components')
    else
      redirect to("/components/#{params[:id]}")
    end
  end
end