require 'spec_helper'

describe ApplicationController do 
  describe 'Homepage' do
    it 'loads the homepage' do
      get '/'
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include("Welcome to GearTracker")
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

  describe 'index action' do
    context 'logged in' do 
      it 'lets a user view their categories index if logged in' do 
        user1 = User.create(:username => "user1", :email => "user1@email.com", :password => "user1password")
        category1 = Category.create(:name => "category1", :description => "Category 1 description.")

        user2 = User.create(:username => "user2", :email => "user2@email.com", :password => "user2password")
        category2 = Category.create(:name => "category2", :description => "Category 2 description.")

        visit '/login'

        fill_in(:username, :with => "user1")
        fill_in(:password, :with => "user1password")
        click_button 'submit'
        visit '/categories'
        expect(page.body).to include(category1)
        expect(page.body).to_not include(category2)
      end
    end

end