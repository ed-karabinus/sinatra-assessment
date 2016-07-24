class Category < ActiveRecord::Base
  belongs_to :user
  has_many :components
  validates_presence_of :name, :description
  validates_presence of :user_id, on: :create
end