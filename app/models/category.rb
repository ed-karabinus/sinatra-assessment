class Category < ActiveRecord::Base
  belongs_to :user
  has_many :component_categories
  has_many :components, through: component_categories
  validates_presence_of :name, :description
  validates_presence of :user_id, on: :create
end