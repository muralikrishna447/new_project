describe Api::V0::ChargesController do
  context 'POST /create' do

    it 'should error if not logged in' do
      post :create, skus: [1000]
      expect(response.status).to eq(401)
    end

    context 'logged in' do
      before :each do
        @user = Fabricate :user, email: 'johndoe@chefsteps.com', password: '123456', name: 'John Doe'
        @setting = Fabricate :setting, premium_membership_price: 31393.22
        token = ActorAddress.create_for_user(@user, client_metadata: "create").current_token
        request.env['HTTP_AUTHORIZATION'] = token.to_jwt
      end

      it 'should error if purchasing anything other than premium membership' do
        post :create, skus: '[1000, 2000]'
        expect(response.status).to eq(422)
      end

      it 'should queue charge and make member premium when called correctly' do
        User.any_instance.should_receive(:make_premium_member)
        Resque.should_receive(:enqueue)
        post :create, skus: '[1000]', stripeToken: 'xxx'
        expect(response.status).to eq(200)
      end

      it 'should error if user is already premium' do
        @user.make_premium_member(10)
        post :create, skus: '[1000]', stripeToken: 'xxx'
        expect(response.status).to eq(422)
      end
    end
  end
end