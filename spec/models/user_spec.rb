describe 'User' do 
  before do 
    @user = User.create(:username => "T$+& 123 .()\'", :email => "test123@gmail.com", :password => "test")
  end
  
  it 'can slug the username' do
    expect(@user.slug).to eq("Tsplusand-123-")
  end

  it 'can find a user based on the slug' do 
    slug = @user.slug
    expect(User.find_by_slug(slug).username).to eq("T$+& 123 .()\'")
  end

  it 'has a secure password' do 
    expect(@user.authenticate("dog")).to eq(false)
    expect(@user.authenticate("test")).to eq(@user)
  end
end