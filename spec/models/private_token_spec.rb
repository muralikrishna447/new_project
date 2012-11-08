describe PrivateToken, '#token' do
  it "returns token from first PrivateToken record" do
    PrivateToken.create(token: 'SECRET')
    PrivateToken.token.should == 'SECRET'
  end
end

describe PrivateToken, '#valid?' do
  before do
    PrivateToken.create(token: 'SECRET')
  end

  it "is invalid if token is nil" do
    PrivateToken.valid?(nil).should_not be
  end

  it "is invalid if token does not match private token" do
    PrivateToken.valid?('BAD_SECRET').should_not be
  end

  it "is valid if token matches private token" do
    PrivateToken.valid?('SECRET').should be
  end
end
