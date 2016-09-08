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

  describe 'new category action' do
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

      it 'lets user create a category that is unique to them if they are logged in' do
        user = User.create(:username => "user1", :email => "user1@email.com", :password => "user1password")
        user2 = User.create(:username => "user2", :email => "user2@email.com", :password => "user2password")

        visit '/login'

        fill_in(:username, :with => "user1")
        fill_in(:password, :with => "user1password")
        click_button 'submit'

        visit '/categories/new'
        fill_in(:name, :with => "category1")
        fill_in(:description, :with => "Category 1 description.")
        click_button 'submit'

        user = User.find_by(:username => "user1")
        user2 = User.find_by(:username => "user2")
        category = Category.find_by(:name => "category1")
        expect(category).to be_instance_of(Category)
        expect(category.user_id).to eq(user.id)
        expect(category.user_id).not_to eq(user2.id)
        expect(page.status_code).to eq(200)
      end

      it 'does not let a user create a category with a null name' do 
        user = User.create(:username => "user1", :email => "user1@email.com", :password => "user1password")

        visit '/login'

        fill_in(:username, :with => "user1")
        fill_in(:password, :with => "user1password")
        click_button 'submit'

        visit '/categories/new'

        fill_in(:name, :with => "")
        fill_in(:description, :with => "Category 1 description.")
        click_button 'submit'

        expect(Category.find_by(:name => "")).to eq(nil)
        expect(page.current_path).to eq('/categories/new')
      end

      it 'does not let a user create a category with a null description' do
        user = User.create(:username => "user1", :email => "user1@email.com", :password => "user1password")

        visit '/login'

        fill_in(:username, :with => "user1")
        fill_in(:password, :with => "user1password")
        click_button 'submit'

        visit '/categories/new'

        fill_in(:name, :with => "Category 1")
        fill_in(:description, :with => "")
        click_button 'submit'

        expect(Category.find_by(:description => "")).to eq(nil)
        expect(page.current_path).to eq('/categories/new')
      end
    end

    context 'logged out' do
      it 'does not let a user view new category form if not logged in' do 
        get '/categories/new'
        expect(last_response.location).to include('/login')
      end
    end
  end

  describe 'categories index action' do
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

  describe 'show categories action' do 
    let!(:user) { user = User.create(:username => "user1", :email => "user1@email.com", :password => "user1password") }
    let!(:category) { Category.create(:name => "category1", :description => "Category 1 description.", :user_id => user.id) }
    
    context 'logged in' do 
      it 'displays a single category' do
        visit '/login'

        fill_in(:username, :with => "user1")
        fill_in(:password, :with => "user1password")
        click_button 'submit'

        visit "/categories/#{category.id}"
        expect(page.status_code).to eq(200)
        expect(page.body).to include("Delete Category")
        expect(page.body).to include(category.name)
        expect(page.body).to include(category.description)
        expect(page.body).to include("Edit Category")
      end
    end

    context 'logged out' do
      it 'does not let a user view a category' do
        get "/categories/#{category.id}"
        expect(last_response.location).to include('/login')
      end
    end
  end

  describe 'edit categories action' do 
    context 'logged in' do 
      it 'lets a user view category edit form if they are logged in' do 
        user = User.create(:username => "user1", :email => "user1@email.com", :password => "user1password")
        category = Category.create(:name => "category1", :description => "Category 1 description.", :user_id => user.id)
        visit '/login'

        fill_in(:username, :with => "user1")
        fill_in(:password, :with => "user1password")
        click_button 'submit'
        visit '/categories/1/edit'
        expect(page.status_code).to eq(200)
        expect(page.body).to include(category.name)
        expect(page.body).to include(category.description)
      end

      it 'submits the edit form via a PATCH request' do
        user = User.create(:username => "user1", :email => "user1@email.com", :password => "user1password")
        category = Category.create(:name => "category1", :description => "Category 1 description.", :user_id => user.id)
        visit '/login'

        fill_in(:username, :with => "user1")
        fill_in(:password, :with => "user1password")
        click_button 'submit'
        visit '/categories/1/edit'

        expect(find("#hidden", :visible => :false).value).to eq("PATCH")
      end

      it 'does not let a user edit a category they did not create' do
        user1 = User.create(:username => "user1", :email => "user1@email.com", :password => "user1password")
        category1 = Category.create(:name => "category1", :description => "Category 1 description.", :user_id => user1.id)

        user2 = User.create(:username => "user2", :email => "user2@email.com", :password => "user2password")
        category2 = Category.create(:name => "category2", :description => "Category 2 description.", :user_id => user2.id)

        visit '/login'

        fill_in(:username, :with => "user1")
        fill_in(:password, :with => "user1password")
        click_button 'submit'
        session = {}
        session[:user_id] = user1.id
        visit "/categories/#{category2.id}/edit"
        expect(page.current_path).to include('/categories')
      end

      it 'lets a user edit their own category if they are logged in' do 
        user = User.create(:username => "user1", :email => "user1@email.com", :password => "user1password")
        category = Category.create(:name => "category1", :description => "Category 1 description.", :user_id => user.id)
        visit '/login'

        fill_in(:username, :with => "user1")
        fill_in(:password, :with => "user1password")
        click_button 'submit'
        visit "/categories/#{category.id}/edit"

        fill_in(:name, :with => "modified_category1")
        fill_in(:description, :with => "Modified Category 1 description.")
        click_button 'submit'
        expect(Category.find_by(:name => "category1")).to eq(nil)
        expect(Category.find_by(:name => "modified_category1")).to be_instance_of(Category)

        expect(page.status_code).to eq(200)
      end

      it 'does not let a user edit a category with blank text for the description' do
        user = User.create(:username => "user1", :email => "user1@email.com", :password => "user1password")
        category = Category.create(:name => "category1", :description => "Category 1 description.", :user_id => user.id)
        visit '/login'

        fill_in(:username, :with => "user1")
        fill_in(:password, :with => "user1password")
        click_button 'submit'
        visit "/categories/#{category.id}/edit"

        fill_in(:description, :with => "")
        click_button 'submit'
        expect(Category.find_by(:description => "")).to be(nil)
        expect(page.current_path).to eq("/categories/#{category.id}/edit")
      end

      it 'does not let a user edit a category with blank text for the name' do
        user = User.create(:username => "user1", :email => "user1@email.com", :password => "user1password")
        category = Category.create(:name => "category1", :description => "Category 1 description.", :user_id => user.id)
        visit '/login'

        fill_in(:username, :with => "user1")
        fill_in(:password, :with => "user1password")
        click_button 'submit'
        visit "/categories/#{category.id}/edit"

        fill_in(:name, :with => "")
        click_button 'submit'
        expect(Category.find_by(:name => "")).to be(nil)
        expect(page.current_path).to eq("/categories/#{category.id}/edit")
      end
    end

    context "logged out" do
      it 'does not load let user view category edit form if not logged in' do 
        get '/categories/1/edit'
        expect(last_response.location).to include('/login')
      end
    end
  end

  describe 'delete categories action' do
    context 'logged in' do
      it 'lets a user delete their own category if they are logged in' do
        user = User.create(:username => "user1", :email => "user1@email.com", :password => "user1password")
        category = Category.create(:name => "category1", :description => "Category 1 description.", :user_id => user.id)
        visit '/login'

        fill_in(:username, :with => "user1")
        fill_in(:password, :with => "user1password")
        click_button 'submit'

        visit "/categories/#{category.id}"
        click_button "Delete Category"
        expect(page.status_code).to eq(200)
        expect(Category.find_by(:description => "Category 1 description.")).to eq(nil)
      end

      it 'deletes a category via a DELETE request' do
        user = User.create(:username => "user1", :email => "user1@email.com", :password => "user1password")
        category = Category.create(:name => "category1", :description => "Category 1 description.", :user_id => user.id)
        visit '/login'

        fill_in(:username, :with => "user1")
        fill_in(:password, :with => "user1password")
        click_button 'submit'

        visit "/categories/#{category.id}"
        expect(find("#hidden", :visible => :false).value).to eq("DELETE")
      end

      it 'does not let a user delete a category they did not create' do
        user1 = User.create(:username => "user1", :email => "user1@email.com", :password => "user1password")
        category1 = Category.create(:name => "category1", :description => "Category 1 description.", :user_id => user1.id)

        user2 = User.create(:username => "user2", :email => "user2@email.com", :password => "user2password")
        category2 = Category.create(:name => "category2", :description => "Category 2 description.", :user_id => user2.id)

        visit '/login'

        fill_in(:username, :with => "user1")
        fill_in(:password, :with => "user1password")
        click_button 'submit'

        visit "/categories/#{category2.id}"
        click_button "Delete Category"
        expect(page.status_code).to eq(200)
        expect(Category.find_by(:name => "category1")).to be_instance_of(Category)
        expect(page.current_path).to include('/categories')
      end
    end

    context 'logged out' do
      it 'does not let a user delete a category if not logged in' do
        category = Category.create(:name => "category1", :description => "Category 1 description.", :user_id => 1)
        visit "/categories/#{category.id}"
        expect(page.current_path).to eq("/login")
      end
    end
  end

  describe 'components index action' do
    context 'logged in' do 
      it 'lets a user view their components index if logged in' do 
        user1 = User.create(:username => "user1", :email => "user1@email.com", :password => "user1password")
        category1 = Category.create(:name => "category1", :description => "Category 1 description.", :user_id => user1.id)
        component1 = Component.create(:name => "component1", :description => "Component 1 description.", :category_id => category1.id)

        user2 = User.create(:username => "user2", :email => "user2@email.com", :password => "user2password")
        category2 = Category.create(:name => "category2", :description => "Category 2 description.", :user_id => user2.id)
        component2 = Component.create(:name => "component2", :description => "Component 2 description.", :category_id => category2.id)

        visit '/login'

        fill_in(:username, :with => "user1")
        fill_in(:password, :with => "user1password")
        click_button 'submit'
        visit '/components'
        expect(page.body).to include(component1.name)
        expect(page.body).to include(component1.description)
        expect(page.body).to_not include(component2.name)
        expect(page.body).to_not include(component2.description)
      end
    end

    context 'logged out' do 
      it 'does not let a user view the components index if not logged in' do
        get '/components'
        expect(last_response.location).to include("/login")
      end
    end
  end

  describe 'new component action' do
    context 'logged in' do
      let!(:user) { User.create(:username => "user1", :email => "user1@email.com", :password => "user1password") }
      let!(:category) { Category.create(:name => "category1", :description => "Category 1 description.", :user_id => user.id)}
      
      it 'lets user view new component form if logged in' do
        visit '/login'

        fill_in(:username, :with => "user1")
        fill_in(:password, :with => "user1password")

        click_button 'submit'
        visit '/components/new'
        expect(page.status_code).to eq(200)
      end

      it 'lets user create a component that is unique to them if they are logged in' do
        user2 = User.create(:username => "user2", :email => "user2@email.com", :password => "user2password")
        category2 = Category.create(:name => "category2", :description => "Category 2 description.", :user_id => user2.id)

        visit '/login'
        fill_in(:username, :with => "user1")
        fill_in(:password, :with => "user1password")
        click_button 'submit'

        visit '/components/new'
        fill_in(:name, :with => "component1")
        fill_in(:description, :with => "Component 1 description.")
        choose("#{category.name}")
        click_button 'submit'

        category = Category.find_by(:name => "category1")
        category2 = Category.find_by(:name => "category2")
        component = Component.find_by(:name => "component1")
        expect(component).to be_instance_of(Component)
        expect(component.category_id).to eq(category.id)
        expect(component.category_id).not_to eq(category2.id)
        expect(page.status_code).to eq(200)
      end

      it 'does not let a user create a component with a null name' do 
        visit '/login'

        fill_in(:username, :with => "user1")
        fill_in(:password, :with => "user1password")
        click_button 'submit'

        visit '/components/new'

        fill_in(:name, :with => "")
        fill_in(:description, :with => "Component 1 description.")
        choose("#{category.name}")
        click_button 'submit'

        expect(Component.find_by(:name => "")).to eq(nil)
        expect(page.current_path).to eq('/components/new')
      end

      it 'does not let a user create a component with a null description' do
        visit '/login'

        fill_in(:username, :with => "user1")
        fill_in(:password, :with => "user1password")
        click_button 'submit'

        visit '/components/new'

        fill_in(:name, :with => "component1")
        fill_in(:description, :with => "")
        choose("#{category.name}")
        click_button 'submit'

        expect(Component.find_by(:description => "")).to eq(nil)
        expect(page.current_path).to eq('/components/new')
      end
    end

    context 'logged out' do
      it 'does not let a user view new component form if not logged in' do 
        get '/components/new'
        expect(last_response.location).to include('/login')
      end
    end
  end

  describe 'show components action' do 
    let!(:user) { user = User.create(:username => "user1", :email => "user1@email.com", :password => "user1password") }
    let!(:category) { Category.create(:name => "category1", :description => "Category 1 description.", :user_id => user.id) }
    let!(:component) { Component.create(:name => "component1", :description => "Component 1 description.", :category_id => category.id) }
    
    context 'logged in' do 
      it 'displays a single component' do
        visit '/login'

        fill_in(:username, :with => "user1")
        fill_in(:password, :with => "user1password")
        click_button 'submit'

        visit "/components/#{component.id}"
        expect(page.status_code).to eq(200)
        expect(page.body).to include("Delete Component")
        expect(page.body).to include(component.name)
        expect(page.body).to include(component.description)
        expect(page.body).to include(component.category.name)
        expect(page.body).to include("Edit Component")
      end
    end

    context 'logged out' do
      it 'does not let a user view a component' do
        get "/components/#{component.id}"
        expect(last_response.location).to include('/login')
      end
    end
  end

  describe 'edit components action' do 
    let!(:user) { User.create(:username => "user1", :email => "user1@email.com", :password => "user1password") }
    let!(:category) { Category.create(:name => "category1", :description => "Category 1 description.", :user_id => user.id) }
    let!(:component) { Component.create(:name => "component1", :description => "Component 1 description.", :category_id => category.id) }

    context 'logged in' do 
      it 'lets a user view component edit form if they are logged in' do 
        visit '/login'

        fill_in(:username, :with => "user1")
        fill_in(:password, :with => "user1password")
        click_button 'submit'
        visit "/components/#{component.id}/edit"
        expect(page.status_code).to eq(200)
        expect(page.body).to include(component.name)
        expect(page.body).to include(component.description)
      end

      it 'submits the edit form via a PATCH request' do
        visit '/login'

        fill_in(:username, :with => "user1")
        fill_in(:password, :with => "user1password")
        click_button 'submit'
        visit "/components/#{component.id}/edit"

        expect(find("#hidden", :visible => :false).value).to eq("PATCH")
      end

      it 'does not let a user edit a component they did not create' do
        user2 = User.create(:username => "user2", :email => "user2@email.com", :password => "user2password")
        category2 = Category.create(:name => "category2", :description => "Category 2 description.", :user_id => user2.id)
        component2 = Component.create(:name => "component2", :description => "Component 2 description.", :category_id => category2.id) 

        visit '/login'

        fill_in(:username, :with => "user1")
        fill_in(:password, :with => "user1password")
        click_button 'submit'
        session = {}
        session[:user_id] = user.id
        visit "/components/#{component2.id}/edit"
        expect(page.current_path).to include('/components')
      end

      it 'lets a user edit their own component if they are logged in' do 
        visit '/login'

        fill_in(:username, :with => "user1")
        fill_in(:password, :with => "user1password")
        click_button 'submit'
        visit "/components/#{component.id}/edit"

        fill_in(:name, :with => "modified_component1")
        fill_in(:description, :with => "Modified Component 1 description.")
        click_button 'submit'
        expect(Component.find_by(:name => "component1")).to eq(nil)
        component = Component.find_by(:name => "modified_component1")
        expect(component).to be_instance_of(Component)
        expect(component.description).to eq("Modified Component 1 description.")

        expect(page.status_code).to eq(200)
      end

      it 'does not let a user edit a component with blank text for the description' do
        visit '/login'

        fill_in(:username, :with => "user1")
        fill_in(:password, :with => "user1password")
        click_button 'submit'
        visit "/components/#{component.id}/edit"

        fill_in(:description, :with => "")
        click_button 'submit'
        expect(Component.find_by(:description => "")).to be(nil)
        expect(page.current_path).to eq("/components/#{component.id}/edit")
      end

      it 'does not let a user edit a component with blank text for the name' do
        visit '/login'

        fill_in(:username, :with => "user1")
        fill_in(:password, :with => "user1password")
        click_button 'submit'
        visit "/components/#{component.id}/edit"

        fill_in(:name, :with => "")
        click_button 'submit'
        expect(Component.find_by(:name => "")).to be(nil)
        expect(page.current_path).to eq("/components/#{component.id}/edit")
      end
    end

    context "logged out" do
      it 'does not load let user view component edit form if not logged in' do 
        get '/components/1/edit'
        expect(last_response.location).to include('/login')
      end
    end
  end

  describe 'delete components action' do
    let!(:user) { User.create(:username => "user1", :email => "user1@email.com", :password => "user1password") }
    let!(:category) { Category.create(:name => "category1", :description => "Category 1 description.", :user_id => user.id) }
    let!(:component) { Component.creeate(:name => "component1", :description => "Component 1 description.", :category_id => category.id) }

    context 'logged in' do
      it 'lets a user delete their own component if they are logged in' do
        visit '/login'

        fill_in(:username, :with => "user1")
        fill_in(:password, :with => "user1password")
        click_button 'submit'

        visit "/components/#{component.id}"
        click_button "Delete Component"
        expect(page.status_code).to eq(200)
        expect(Category.find_by(:description => "Component 1 description.")).to eq(nil)
      end

      it 'deletes a component via a DELETE request' do
        visit '/login'

        fill_in(:username, :with => "user1")
        fill_in(:password, :with => "user1password")
        click_button 'submit'

        visit "/components/#{component.id}"
        expect(find("#hidden", :visible => :false).value).to eq("DELETE")
      end

      it 'does not let a user delete a category they did not create' do
        user2 = User.create(:username => "user2", :email => "user2@email.com", :password => "user2password")
        category2 = Category.create(:name => "category2", :description => "Category 2 description.", :user_id => user2.id)
        component2 = Component.create(:name => "component2", :description => "Component 2 description.", :category_id => category2.id)

        visit '/login'

        fill_in(:username, :with => "user1")
        fill_in(:password, :with => "user1password")
        click_button 'submit'

        visit "/components/#{component2.id}"
        click_button "Delete Component"
        expect(page.status_code).to eq(200)
        expect(Component.find_by(:name => "component1")).to be_instance_of(Component)
        expect(page.current_path).to include('/components')
      end
    end

    context 'logged out' do
      it 'does not let a user delete a component if not logged in' do
        visit "/components/#{component.id}"
        expect(page.current_path).to eq("/login")
      end
    end
  end
end