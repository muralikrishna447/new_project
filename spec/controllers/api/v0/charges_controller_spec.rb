describe Api::V0::ChargesController do
  premium_sku = '["cs10000"]'

  context 'POST /create' do

    it 'should error if not logged in' do
      post :create, skus: premium_sku
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
        post :create, skus: '["blah"]'
        expect(response.status).to eq(422)
      end

      it 'should queue charge and make member premium when called correctly' do
        User.any_instance.should_receive(:make_premium_member)
        Resque.should_receive(:enqueue)
        post :create, skus: premium_sku, stripeToken: 'xxx'
        expect(response.status).to eq(200)
      end

      it 'should error if user is already premium' do
        @user.make_premium_member(10)
        post :create, skus: premium_sku, stripeToken: 'xxx'
        expect(response.status).to eq(422)
      end

      it 'should queue charge and create gift certificate when called correctly' do
        Resque.should_receive(:enqueue)
        post :create, skus: premium_sku, gift: "true", stripeToken: 'xxx'
        expect(PremiumGiftCertificate.count).to eq(1)
        expect(PremiumGiftCertificate.last.redeemed).to eq(false)
        expect(response.status).to eq(200)
      end

      it 'should redeem a valid gift certificate' do
        gc = Fabricate :premium_gift_certificate
        User.any_instance.should_receive(:make_premium_member)
        put :redeem, id: gc.token
      end
    end
  end
end