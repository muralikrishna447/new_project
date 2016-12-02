describe Api::V0::RandomDropsController do

  before :each do
    @user = Fabricate :user, name: 'User Random Drop', email: 'user@random.drop'
    sign_in @user
    controller.request.env['HTTP_AUTHORIZATION'] = @user.valid_website_auth_token.to_jwt
    RandomDrop.stub(:get).and_return({
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
    parsed['user_id'].should eq(1)
    parsed['discount_code'].should eq('RANDOMDISCOUNT')
    parsed['variant_id'].should eq('VARIANTID')

  end

end
