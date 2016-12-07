describe Api::V0::RandomDropsController do

  before :each do
    @user = Fabricate :user, name: 'User Random Drop', email: 'user@random.drop'
    sign_in @user
    controller.request.env['HTTP_AUTHORIZATION'] = @user.valid_website_auth_token.to_jwt
    RandomDrop.stub(:query).and_return({
      'user_id' => @user.id,
      'discount_code' => 'RANDOMDISCOUNT',
      'variant_id' => 'VARIANTID',
      'price' => '49'
    })
  end

  # GET /api/v0/random_drops/:id
  it 'should return random drop for a user with id' do
    get :show, id: @user.id
    response.should be_success
    parsed = JSON.parse response.body
    parsed['user_id'].should eq(@user.id)
    parsed['discount_code'].should eq('RANDOMDISCOUNT')
    parsed['variant_id'].should eq('VARIANTID')
    parsed['url'].should eq("https://store.chefsteps-test-endpoint.com/cart/VARIANTID:1?discount=RANDOMDISCOUNT")
  end

  it 'should not return a random drop if user id does not match authenticated user' do
    get :show, id: 4
    response.should_not be_success
  end

  it 'should return a random drop if user is admin' do
    @admin = Fabricate :user, name: 'Admin Random Drop', email: 'admin@random.drop', role: 'admin'
    sign_in @admin
    controller.request.env['HTTP_AUTHORIZATION'] = @admin.valid_website_auth_token.to_jwt
    get :show, id: @user.id
    response.should be_success
  end

end
