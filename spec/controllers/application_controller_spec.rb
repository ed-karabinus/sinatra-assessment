require 'spec_helper'

describe ApplicationController do 
  describe 'Homepage' do
    it 'loads the homepage' do
      get '/'
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include("GearTracker")
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

    context 'without a username' do
      let!(:params) { {
          :username => "",
          :email => "user1@email.com",
          :password => "user1password"
        } }

      it 'does not let a user sign up' do
        post '/signup', params
        expect(last_response.location).to include('/signup')
      end

      it 'displays an error when a user attempts to sign up' do
        post '/signup', params
        follow_redirect!
        expect(last_response.body).to include("Username can't be blank. Please try again.")
      end

      it 'populates only the email field on the sign up form after validation failure when a user attempts to sign up' do
        post '/signup', params
        follow_redirect!
        expect(last_response.body).to include("value=\"user1@email.com\"")
        expect(last_response.body).not_to include("value=\"user1\"")
      end
    end

    context 'without an email' do
      let!(:params) { {
          :username => "user1",
          :email => "", 
          :password => "user1password"
        } }

      it 'does not let a user sign up' do
        post '/signup', params
        expect(last_response.location).to include('/signup')
      end

      it 'displays an error when a user attempts to sign up' do
        post '/signup', params
        follow_redirect!
        expect(last_response.body).to include("Email can't be blank. Please try again.")
      end

      it 'populates only the username field on the sign up form after validation failure when a user attempts to sign up' do
        post '/signup', params
        follow_redirect!
        expect(last_response.body).not_to include("value=\"user1@email.com\"")
        expect(last_response.body).to include("value=\"user1\"")
      end
    end

    context 'without a password' do
      let!(:params) { {
        :username => "user1",
        :email => "user1@email.com",
        :password => ""
        } }

      it 'does not let a user sign up' do 
        post '/signup', params
        expect(last_response.location).to include('/signup')
      end

      it 'displays an error when a user attempts to sign up' do
        post '/signup', params
        follow_redirect!
        expect(last_response.body).to include("Password can't be blank. Please try again.")
      end

      it 'populates the username and email fields on the sign up form after validation failure when a user attempts to sign up' do
        post '/signup', params
        follow_redirect!
        expect(last_response.body).to include("value=\"user1@email.com\"")
        expect(last_response.body).to include("value=\"user1\"")
      end
    end

    context 'with a duplicate username' do
      let!(:params) { {
        :username => "user1",
        :password => "user1password",
        :email => "user1@email.com"
        } }

      it 'does not let a user sign up' do
        User.create(params)
        post '/signup', params
        expect(last_response.location).to include('/signup')
      end

      it 'displays an error when a user attempts to sign up' do
        User.create(params)
        post '/signup', params
        follow_redirect!
        expect(last_response.body).to include('Username has already been taken. Please try again.')
      end

      it 'populates only the email field on the sign up form after validation failure when a user attempts to sign up' do
        User.create(params)
        post '/signup', params
        follow_redirect!
        expect(last_response.body).to include("value=\"user1@email.com\"")
        expect(last_response.body).not_to include("value=\"user1\"")
      end
    end

    it 'does not let a logged in user view the signup page' do 
      params = {
        :username => "user",
        :email => "user1@email.com",
        :password => "user1password"
      }
      user = User.create(params)
      post '/login', params

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
      expect(last_response.body).to include("Categories")
    end

    it 'does not let the user view login page if already logged in' do
      params = {
        :username => "user1",
        :password => "user1password"
      }

      user = User.create(params.merge(:email => "user1@email.com"))

      post '/login', params

      get '/login'
      expect(last_response.location).to include("/categories")
    end

    context 'without the correct credentials' do
      let!(:params) { {
        :username => "user1",
        :password => "user1password",
        :email => "user1@email.com"
      } }

      let!(:incorrect_params) { {
        :username => "",
        :password => ""
      } }

      it 'does not let a user log in' do
        user = User.create(params)

        post '/login', incorrect_params
        expect(last_response.location).to include("/login")
      end

      it 'displays an error when a user attempts to log in' do
        user = User.create(params)

        post '/login', incorrect_params
        follow_redirect!
        expect(last_response.body).to include("Invalid credentials. Please try again.")
      end
    end
  end

  describe 'logout' do 
    context 'logged in' do
      let!(:params) { {
        :username => "user1",
        :password => "user1password",
        :email => "user1@email.com"
      } }
      
      it 'lets a user logout' do 
        params = {
          :username => "user1",
          :password => "user1password"
        }
        user = User.create(params.merge(:email => "user1@email.com"))

        post '/login', params
        get '/logout'
        expect(last_response.location).to include('/login')
      end

      it 'does load /categories' do
        user = User.create(params)
        
        visit '/login'

        fill_in(:username, :with => "user1")
        fill_in(:password, :with => "user1password")
        click_button 'submit'

        expect(page.current_path).to eq('/categories')
      end
    end

    context 'logged out' do
      it 'does not let a user logout' do
        get '/logout'
        expect(last_response.location).to include('/')
      end

      it 'does not load /categories' do
        get '/categories'
        expect(last_response.location).to include('/login')
      end
    end
  end

  describe 'user show page' do 
    let!(:user1) { User.create(:username => "user1", :email => "user1@email.com", :password => "user1password") }
    let!(:category1) { Category.create(:name => "category1", :description => "Category 1 description.", :user_id => user1.id) }
    let!(:category2) { Category.create(:name => "category2", :description => "Category 2 description.", :user_id => user1.id) }

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