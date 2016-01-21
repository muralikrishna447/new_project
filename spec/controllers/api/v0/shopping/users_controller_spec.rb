describe Api::V0::Shopping::UsersController do
  before :each do
    ShopifyAPI::Base.stub(:site).and_return(URI.parse('https://test.myshopify.com/admin'))
    Shopify::Multipass.any_instance.stub(:generate_token).and_return('abc123')
  end

  context 'GET /multipass or /add_to_cart' do
    before :each do
      @user = Fabricate :user, email: "test@example.com", name: "Tester Example"
      sign_in @user
    end

    describe 'autoredirect' do
      it 'should redirect from and to multipass' do
        get :multipass, {product_id: 123, quantity: 1, autoredirect: true}
        response.should redirect_to("https://chefsteps-staging.myshopify.com/account/login/multipass/abc123")
      end
      it 'should redirect from add_to_cart to multipass' do
        get :add_to_cart, {variant_id: 123}
        response.should redirect_to("https://chefsteps-staging.myshopify.com/account/login/multipass/abc123")
      end
    end
  end
end
