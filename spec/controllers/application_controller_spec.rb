require 'spec_helper'

describe ApplicationController do 
  describe 'Homepage' do
    it 'loads the homepage' do
      get '/'
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include("Welcome to GearTracker")
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