require 'spec_helper'

describe ComponentsController do 
  describe 'components index action' do
    context 'logged in' do 
      it 'lets a user view their components index' do 
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
      
      it 'lets user view new component form' do
        visit '/login'

        fill_in(:username, :with => "user1")
        fill_in(:password, :with => "user1password")

        click_button 'submit'
        visit '/components/new'
        expect(page.status_code).to eq(200)
      end

      it 'lets user create a component that is unique to them' do
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

      context 'with a null name' do
        it 'does not let a user create a component' do 
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

        it 'displays an error message when a user attempts to create a component' do 
          visit '/login'

          fill_in(:username, :with => "user1")
          fill_in(:password, :with => "user1password")
          click_button 'submit'

          visit '/components/new'

          fill_in(:name, :with => "")
          fill_in(:description, :with => "Component 1 description.")
          choose("#{category.name}")
          click_button 'submit'

          expect(page.body).to include("Name can't be blank. Please try again.")
        end

        it 'populates the description and category_id fields on the component creation form when a user attempts to create a component' do
          visit '/login'

          fill_in(:username, :with => "user1")
          fill_in(:password, :with => "user1password")
          click_button 'submit'

          visit '/components/new'

          fill_in(:name, :with => "")
          fill_in(:description, :with => "Component 1 description.")
          choose("#{category.name}")
          click_button 'submit'

          expect(page.body).to include("Component 1 description.")
          expect(find("##{category.id}")).to be_checked
        end
      end

      context 'with a null description' do
        before(:each) do
          visit '/login'

          fill_in(:username, :with => "user1")
          fill_in(:password, :with => "user1password")
          click_button 'submit'

          visit '/components/new'

          fill_in(:name, :with => "component1")
          fill_in(:description, :with => "")
          choose("#{category.name}")
          click_button 'submit'
        end

        it 'does not let a user create a component' do
          expect(Component.find_by(:description => "")).to eq(nil)
          expect(page.current_path).to eq('/components/new')
        end

        it 'displays an error message when a user attempts to create a component' do
          expect(page.body).to include("Description can't be blank. Please try again.")
        end

        it 'populates only the name and category_id fields on the component creation form when a user attempts to create a component' do
          expect(page.body).to include("component1")
          expect(find("##{category.id}")).to be_checked
        end
      end

      context 'without a category' do
        before(:each) do
          visit '/login'

          fill_in(:username, :with => "user1")
          fill_in(:password, :with => "user1password")
          click_button 'submit'

          visit '/components/new'

          fill_in(:name, :with => "component1")
          fill_in(:description, :with => "Component 1 description.")
          click_button 'submit'
        end

        it 'does not let a user create a component' do
          expect(Component.find_by(:description => "")).to eq(nil)
          expect(page.current_path).to eq('/components/new')
        end

        it 'displays an error message when a user attempts to create a component' do
          expect(page.body).to include("Category_id can't be blank. Please try again.")
        end

        it 'populates only the name and description fields on the component creation form when a user attempts to create a component' do
          expect(page.body).to include("component1")
          expect(page.body).to include("Component 1 description.")
          expect(find("##{category.id}")).not_to be_checked
        end
      end

      it "lists a user\'s categories in the component creation form" do
        visit '/login'

        fill_in(:username, :with => "user1")
        fill_in(:password, :with => "user1password")
        click_button 'submit'

        visit '/components/new'
        expect(page.status_code).to eq(200)
        expect(page.body).to include("category1")
      end
    end

    context 'logged out' do
      it 'does not let a user view new component form' do 
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
      before(:each) do
        visit '/login'

        fill_in(:username, :with => "user1")
        fill_in(:password, :with => "user1password")
        click_button 'submit'
      end

      it 'lets a user view component edit form' do 
        visit "/components/#{component.id}/edit"
        expect(page.status_code).to eq(200)
        expect(page.body).to include(component.name)
        expect(page.body).to include(component.description)
      end

      it 'submits the edit form via a PATCH request' do
        visit "/components/#{component.id}/edit"
        expect(find("#hidden", :visible => :false).value).to eq("PATCH")
      end

      it 'does not let a user edit a component they did not create' do
        user2 = User.create(:username => "user2", :email => "user2@email.com", :password => "user2password")
        category2 = Category.create(:name => "category2", :description => "Category 2 description.", :user_id => user2.id)
        component2 = Component.create(:name => "component2", :description => "Component 2 description.", :category_id => category2.id) 

        visit "/components/#{component2.id}/edit"

        fill_in(:name, :with => "modified_component2")
        click_button 'submit'

        expect(Component.find_by(:name => "modified_component2")).to be(nil)
      end

      it 'lets a user edit their own component' do 
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

      context 'with blank text for the description' do
        it 'does not let a user edit a component' do
          visit "/components/#{component.id}/edit"

          fill_in(:description, :with => "")
          click_button 'submit'
          expect(Component.find_by(:description => "")).to be(nil)
          expect(page.current_path).to eq("/components/#{component.id}/edit")
        end

        it 'displays an error message when a user attempts to edit a component' do
          visit "/components/#{component.id}/edit"

          fill_in(:description, :with => "")
          click_button 'submit'

          expect(page.body).to include("Description can't be blank. Please try again.")
        end
      end

      context 'with blank text for the name' do
        before(:each) do
          visit "/components/#{component.id}/edit"

          fill_in(:name, :with => "")
          click_button 'submit'
        end

        it 'does not let a user edit a component' do
          expect(Component.find_by(:name => "")).to be(nil)
          expect(page.current_path).to eq("/components/#{component.id}/edit")
        end

        it 'displays an error message when a user attempts to edit a component' do
          expect(page.body).to include("Name can't be blank. Please try again.")
        end
      end
    end

    context "logged out" do
      it 'does not load let user view component edit form' do 
        get '/components/1/edit'
        expect(last_response.location).to include('/login')
      end
    end
  end

  describe 'delete components action' do
    let!(:user) { User.create(:username => "user1", :email => "user1@email.com", :password => "user1password") }
    let!(:category) { Category.create(:name => "category1", :description => "Category 1 description.", :user_id => user.id) }
    let!(:component) { Component.create(:name => "component1", :description => "Component 1 description.", :category_id => category.id) }

    context 'logged in' do
      before(:each) do
        visit '/login'

        fill_in(:username, :with => "user1")
        fill_in(:password, :with => "user1password")
        click_button 'submit'
      end

      it 'lets a user delete their own component' do
        visit "/components/#{component.id}"
        click_button "Delete Component"
        expect(page.status_code).to eq(200)
        expect(Category.find_by(:description => "Component 1 description.")).to eq(nil)
      end

      it 'deletes a component via a DELETE request' do
        visit "/components/#{component.id}"
        expect(find("#hidden", :visible => :false).value).to eq("DELETE")
      end

      it 'does not let a user delete a component they did not create' do
        user2 = User.create(:username => "user2", :email => "user2@email.com", :password => "user2password")
        category2 = Category.create(:name => "category2", :description => "Category 2 description.", :user_id => user2.id)
        component2 = Component.create(:name => "component2", :description => "Component 2 description.", :category_id => category2.id)

        visit "/components/#{component2.id}"
        click_button "Delete Component"
        expect(page.status_code).to eq(200)
        expect(Component.find_by(:name => "component1")).to be_instance_of(Component)
        expect(page.current_path).to include('/components')
      end
    end

    context 'logged out' do
      it 'does not let a user delete a component' do
        visit "/components/#{component.id}"
        expect(page.current_path).to eq("/login")
      end
    end
  end
end