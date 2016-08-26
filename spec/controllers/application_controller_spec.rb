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

    it 'does not let a logged in user view the signp page' do 
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


  describe 'user show page' do 
    it "shows all a single user's categories" do
      user1 = User.create(:username => "user1", :email => "user1@email.com", :password => "user1password")
      category1 = Category.create(:name => "category1", :description => "Category 1 description.")
      category2 = Category.create(:name => "category2", :description => "Category 2 description.")
      get "/users/#{user1.slug}"

      expect(last_response.body).to include("category1")
      expect(last_response.body).to include("category2")
      expect(last_response.body).to include("Category 1 description.")
      expect(last_response.body).to include("Category 2 description.")
    end
  end

  describe 'new action' do
    context 'logged in' do
      it 'lets user view new category form if logged in' do
        user = User.create(:username => "user1", :email => "user1@email.com", :password => "user1password")

        visit '/login'

        fill_in(:username, :with => "user1")
        fill_in(:password, :with => "user1password")

        click_button 'submit'
        visit '/categories/new'
        expect(page.status_code).to eq(200)
      end

      it 'lets user create a category if they are logged in' do
        user = User.create(:username => "user1", :email => "user1@email.com", :password => "user1password")

        visit '/login'

        fill_in(:username, :with => "user1")
        fill_in(:password, :with => "user1password")
        click_button 'submit'

        visit '/categories/new'
        fill_in(:name, :with => "category1")
        fill_in(:description, :with => "Category 1 description.")
        click_button 'submit'

        user = User.find_by(:username => "user1")
        category = Category.find_by(:name => "category1")
        expect(category).to be_instance_of(Category)
        expect(category.user_id).to eq(user.id)
        expect(page.status_code).to eq(200)
      end
    end
  end

  describe 'index action' do
    context 'logged in' do 
      it 'lets a user view their categories index if logged in' do 
        user1 = User.create(:username => "user1", :email => "user1@email.com", :password => "user1password")
        category1 = Category.create(:name => "category1", :description => "Category 1 description.", :user_id => user1.id)

        user2 = User.create(:username => "user2", :email => "user2@email.com", :password => "user2password")
        category2 = Category.create(:name => "category2", :description => "Category 2 description.", :user_id => user2.id)

        visit '/login'

        fill_in(:username, :with => "user1")
        fill_in(:password, :with => "user1password")
        click_button 'submit'
        visit '/categories'
        expect(page.body).to include(category1.name)
        expect(page.body).to include(category1.description)
        expect(page.body).to_not include(category2.name)
        expect(page.body).to_not include(category2.description)
      end
    end

    context 'logged out' do 
      it 'does not let a user view the categories index if not logged in' do
        get '/categories'
        expect(last_response.location).to include("/login")
      end
    end
  end
end