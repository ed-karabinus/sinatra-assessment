require 'spec_helper'

describe ApplicationController do 
  describe 'Homepage' do
    it 'loads the homepage' do
      get '/'
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include("Welcome to GearTracker")
    end
  end

  describe 'Signup Page' do 

    it 'loads the signup page' do 
      get '/signup'
      expect(last_response.status).to eq(200)
    end

    it 'signup directs user to categories index' do 
      params = {
        :username => "user1",
        :password => "user1password",
        :email => "user1@email.com"
      }
      post '/signup', params
      expect(last_response.location).to include('/categories')
    end

    it 'does not let a user sign up without a username' do
      params = {
        :username => "",
        :email => "user1@email.com",
        :password => "user1password"
      }
      post '/signup', params
      expect(last_response.location).to include('/signup')
    end

    it 'does not let a user sign up without an email' do
      params = {
        :username => "user1",
        :email => "", 
        :password => "user1password"
      }
      post '/signup', params
      expect(last_response.location).to include('/signup')
    end

    it 'does not let a user sign up without a password' do 
      params = {
        :username => "user1",
        :email => "user1@email.com",
        :password => ""
      }
      post '/signup', params
      expect(last_response.location).to include('/signup')
    end

    it 'does not let a logged in user view the signup page' do 
      params = {
        :username => "user1",
        :email => "user1@email.com",
        :password => "user1password"
      }
      user = User.create(params)
      post '/signup', params
      session = {}
      session[:id] = user.id 
      get '/signup'
      expect(last_response.location).to include('/categories')
    end

  end

  describe 'login' do 
    it 'loads the login page' do
      get '/login'
      expect(last_response.status).to eq(200)
    end

    it "loads the user's categories index after login" do
      params = {
        :username => "user1",
        :password => "user1password"
      }

      user = User.create(params.merge(:email => "user1@email.com"))

      post '/login', params
      expect(last_response.status).to eq(302)

      follow_redirect!
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include("Welcome,")
    end

    it 'does not let the user view login page if already logged in' do
      params = {
        :username => "user1",
        :password => "user1password"
      }

      user = User.create(params.merge(:email => "user1@email.com"))

      post '/login', params
      session = { :id => "user.id" }

      get '/login'
      expect(last_response.location).to include("/categories")
    end
  end

  describe 'logout' do 
    it 'lets a user logout if they are already logged in' do 
      params = {
        :username => "user1",
        :password => "user1password"
      }
      user = User.create(params.merge(:email => "user1@email.com"))

      post '/login', params
      get '/logout'
      expect(last_response.location).to include('/login')
    end

    it 'does not let a user logout if not logged in' do
      get '/logout'
      expect(last_response.location).to include('/')
    end

    it 'does not load /categories if user not logged in' do
      get '/categories'
      expect(last_response.location).to include('/login')
    end

    it 'does load /categories if user is logged in' do
      user = User.create(:username => "user1", :email => "user1@emal.com", :password => "user1password")
      
      visit '/login'

      fill_in(:username, :with => "user1")
      fill_in(:password, :with => "user1password")
      click_button 'submit'

      expect(page.current_path).to eq('/categories')
    end
  end

  describe 'user show page' do 
    user1 = User.create(:username => "user1", :email => "user1@email.com", :password => "user1password")
    category1 = Category.create(:name => "category1", :description => "Category 1 description.", :user_id => user1.id)
    category2 = Category.create(:name => "category2", :description => "Category 2 description.", :user_id => user1.id)

    it "shows all of a user's categories" do
      get "/users/#{user1.slug}"

      expect(last_response.body).to include("category1")
      expect(last_response.body).to include("category2")
      expect(last_response.body).to include("Category 1 description.")
      expect(last_response.body).to include("Category 2 description.")
    end

    it "shows all of a user's components" do
      component1 = Component.create(:name => "component1", :description => "Component 1 description.", :category_id => category1.id)
      component2 = Component.create(:name => "component2", :description => "Component 2 description.", :category_id => category2.id)

      get "/users/#{user1.slug}"
      expect(last_response.body).to include("component1")
      expect(last_response.body).to include("component2")
      expect(last_response.body).to include("Component 1 description.")
      expect(last_response.body).to include("Component 2 description.")
    end
  end
end