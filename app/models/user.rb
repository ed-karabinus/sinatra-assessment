class User < ActiveRecord::Base
  has_secure_password
  validates_presence_of :username, on: :create
  validates_presence_of :password, on: :create
  validates_presence_of :email, on: :create

  def slug
    self.username.downcase.gsub(/[\$\&\+\s]/, {'$' => 's', '&' => 'and', '+' => '+', ' ' => '-'}).gsub(/[\'\.\(\)\,]/, '')
  end

  def self.find_by_slug(slug)
    self.all.detect { |user| user.slug == slug }
  end
end