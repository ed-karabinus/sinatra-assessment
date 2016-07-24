class Component < ActiveRecord::Base
  belongs_to :category
  validates_presence_of :name, :description
  validates_presence_of :category_id, on: :create
end