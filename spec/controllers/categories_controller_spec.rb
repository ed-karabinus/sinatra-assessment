require 'spec_helper'

describe CategoriesController do 
  describe 'new category action' do
    context 'logged in' do
      it 'lets user view new category form' do
        user = User.create(:username => "user1", :email => "user1@email.com", :password => "user1password")

        visit '/login'

        fill_in(:username, :with => "user1")
        fill_in(:password, :with => "user1password")

        click_button 'submit'
        visit '/categories/new'
        expect(page.status_code).to eq(200)
      end

      it 'lets user create a category that is unique to them' do
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

      context 'with a null name' do
          it 'does not let a user create a category' do 
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

          it 'displays an error message when a user attempts to create a category' do
            user = User.create(:username => "user1", :email => "user1@email.com", :password => "user1password")

            visit '/login'

            fill_in(:username, :with => "user1")
            fill_in(:password, :with => "user1password")
            click_button 'submit'

            visit '/categories/new'

            fill_in(:name, :with => "")
            fill_in(:description, :with => "Category 1 description.")
            click_button 'submit'

            expect(page.body).to include("Name can't be blank. Please try again.")
          end

        it 'populates the description field on the category creation form when a user attempts to create a category' do
            user = User.create(:username => "user1", :email => "user1@email.com", :password => "user1password")

            visit '/login'

            fill_in(:username, :with => "user1")
            fill_in(:password, :with => "user1password")
            click_button 'submit'

            visit '/categories/new'

            fill_in(:name, :with => "")
            fill_in(:description, :with => "Category 1 description.")
            click_button 'submit'

            expect(page.body).to include("Name can't be blank. Please try again.")
        end
      end

      context 'with a null description' do
          it 'does not let a user create a category' do
            user = User.create(:username => "user1", :email => "user1@email.com", :password => "user1password")

            visit '/login'

            fill_in(:username, :with => "user1")
            fill_in(:password, :with => "user1password")
            click_button 'submit'

            visit '/categories/new'

            fill_in(:name, :with => "category1")
            fill_in(:description, :with => "")
            click_button 'submit'

            expect(Category.find_by(:description => "")).to eq(nil)
            expect(page.current_path).to eq('/categories/new')
          end

          it 'displays an error message when a user attempts to create a category' do
            user = User.create(:username => "user1", :email => "user1@email.com", :password => "user1password")

            visit '/login'

            fill_in(:username, :with => "user1")
            fill_in(:password, :with => "user1password")
            click_button 'submit'

            visit '/categories/new'

            fill_in(:name, :with => "category1")
            fill_in(:description, :with => "")
            click_button 'submit'

            expect(page.body).to include("Description can't be blank. Please try again.");
          end

          it 'populates only the name field when a user attempts to create a category' do
            user = User.create(:username => "user1", :email => "user1@email.com", :password => "user1password")

            visit '/login'

            fill_in(:username, :with => "user1")
            fill_in(:password, :with => "user1password")
            click_button 'submit'

            visit '/categories/new'

            fill_in(:name, :with => "category1")
            fill_in(:description, :with => "")
            click_button 'submit'

            expect(page.body).to include("category1");
          end
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

        let!(:user) { User.create(:username => "user1", :email => "user1@email.com", :password => "user1password") }
        let!(:category) { Category.create(:name => "category1", :description => "Category 1 description.", :user_id => user.id) }

        before(:each) do
            visit '/login'

            fill_in(:username, :with => "user1")
            fill_in(:password, :with => "user1password")
            click_button 'submit'
        end

      it 'lets a user view category edit form' do 
        visit '/categories/1/edit'
        expect(page.status_code).to eq(200)
        expect(page.body).to include(category.name)
        expect(page.body).to include(category.description)
      end

      it 'submits the edit form via a PATCH request' do
        visit '/categories/1/edit'

        expect(find("#hidden", :visible => :false).value).to eq("PATCH")
      end

      it 'does not let a user edit a category they did not create' do
        user2 = User.create(:username => "user2", :email => "user2@email.com", :password => "user2password")
        category2 = Category.create(:name => "category2", :description => "Category 2 description.", :user_id => user2.id)


        visit "/categories/#{category2.id}/edit"
        fill_in(:name, :with => "modified_category2")
        click_button 'submit'

        expect(Category.find_by(:name => "modified_category2")).to be(nil)
      end

      it 'lets a user edit their own category' do 
        visit "/categories/#{category.id}/edit"

        fill_in(:name, :with => "modified_category1")
        fill_in(:description, :with => "Modified Category 1 description.")
        click_button 'submit'
        expect(Category.find_by(:name => "category1")).to eq(nil)
        expect(Category.find_by(:name => "modified_category1")).to be_instance_of(Category)

        expect(page.status_code).to eq(200)
      end

      context 'with blank text for the description' do
        before(:each) do
            visit "/categories/#{category.id}/edit"

            fill_in(:description, :with => "")
            click_button 'submit'
        end

          it 'does not let a user edit a category' do
            expect(Category.find_by(:description => "")).to be(nil)
            expect(page.current_path).to eq("/categories/#{category.id}/edit")
          end

          it 'displays an error message when a user attempts to edit a category' do
            expect(page.body).to include("Description can't be blank. Please try again.");
          end
      end

      context 'with blank text for the name' do
        before(:each) do
            visit "/categories/#{category.id}/edit"

            fill_in(:name, :with => "")
            click_button 'submit'
        end

          it 'does not let a user edit a category' do
            expect(Category.find_by(:name => "")).to be(nil)
            expect(page.current_path).to eq("/categories/#{category.id}/edit")
          end

          it 'displays an error message when a user attempts to edit a category' do
            expect(page.body).to include("Name can't be blank. Please try again.")
          end
      end
    end

    context "logged out" do
      it 'does not load let user view category edit form' do 
        get '/categories/1/edit'
        expect(last_response.location).to include('/login')
      end
    end
  end

  describe 'delete categories action' do
    context 'logged in' do
      it 'lets a user delete their own category' do
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
      it 'does not let a user delete a category' do
        category = Category.create(:name => "category1", :description => "Category 1 description.", :user_id => 1)
        visit "/categories/#{category.id}"
        expect(page.current_path).to eq("/login")
      end
    end
  end
end