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

end