describe Api::V0::LikesController do

  before :each do
    @user = Fabricate :user, name: 'Admin User', email: 'admin@chefsteps.com'
    @activity = Fabricate :activity, title: 'My New Recipe'
    sign_in @user
    controller.request.env['HTTP_AUTHORIZATION'] = @user.valid_website_auth_token.to_jwt
  end

  # POST /api/v0/likes
  it 'should create a like' do
    post :create, { likeable_type: 'Activity', likeable_id: @activity.id}
    response.should be_success
    parsed = JSON.parse response.body
    parsed['likeable_type'].should eq('Activity')
    parsed['likeable_id'].should eq(@activity.id)
    parsed['user_id'].should eq(@user.id)
  end

  # DELETE /api/v0/likes
  it 'should delete a like' do
    @like = Fabricate :like, id:9999, likeable_id: 'Activity', likeable_id: @activity.id, user_id: @user.id
    delete :destroy, id: @like.id
    response.should be_success
    parsed = JSON.parse response.body
    parsed['likeable_type'].should eq('Activity')
    parsed['likeable_id'].should eq(@activity.id)
    parsed['user_id'].should eq(@user.id)
  end

end
