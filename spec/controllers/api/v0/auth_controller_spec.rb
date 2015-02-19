describe Api::V0::AuthController do

  before :each do
    @user = Fabricate :user, email: 'johndoe@chefsteps.com', password: '123456', name: 'John Doe'
  end

  context 'POST /authenticate' do

    it 'should return a status 400 Bad Request' do
      post :authenticate
      response.should_not be_success
      response.code.should eq("400")
    end

    it 'should return a status 401 Unauthorized if the password is incorrect' do
      post :authenticate, user: {email: 'johndoe@chefsteps.com', password: 'abcdef'}
      response.should_not be_success
      response.code.should eq("401")
    end

    describe 'token' do
      
      before :each do
        post :authenticate, user: {email: 'johndoe@chefsteps.com', password: '123456'}
        response.should be_success
        response.code.should eq("200")
        @token = JSON.parse(response.body)['token']
        @key = OpenSSL::PKey::RSA.new ENV["AUTH_SECRET_KEY"], 'cooksmarter'
        
      end

      it 'should be returned' do
        @token.should_not be_empty
      end

      it 'should be authenticatable with a valid secret' do
        # First decode encryption
        decoded = JSON::JWT.decode(@token, @key)
        # puts "Decoded: #{decoded}"

        # Then decode signature
        verified = JSON::JWT.decode(decoded.to_s, @key.to_s)
        # puts "Verified: #{verified}"
        name = verified['user']['name']
        name.should eq(@user.name)
      end

    end

  end

end