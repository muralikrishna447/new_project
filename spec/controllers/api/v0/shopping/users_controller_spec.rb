describe Api::V0::Shopping::UsersController do
  before :each do
    ShopifyAPI::Base.stub(:site).and_return(URI.parse('https://test.myshopify.com/admin'))
    ShopifyMultipass.any_instance.stub(:generate_token).and_return('abc123')
  end

  context 'GET /multipass' do
    before :each do
      @user = Fabricate :user, email: "test@example.com", name: "Tester Example"
      sign_in @user
    end

    describe 'autoredirect' do
      it 'should redirect to multipass' do
        get :multipass, {product_id: 123, quantity: 1, autoredirect: true}
        response.should redirect_to("https://delve.myshopify.com/account/login/multipass/abc123")
      end

    end
  end

end
