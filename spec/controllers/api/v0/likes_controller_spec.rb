describe Api::V0::LikesController do
  include Docs::V0::Likes::Api

  before :each do
    @user = Fabricate :user, name: 'Admin User', email: 'admin@chefsteps.com'
    @activity = Fabricate :activity, title: 'My New Recipe'
    sign_in @user
    controller.request.env['HTTP_AUTHORIZATION'] = @user.valid_website_auth_token.to_jwt
  end

  describe 'POST #create' do
    include Docs::V0::Likes::Create
    # POST /api/v0/likes
    it 'should create a like', :dox do
      post :create, params: { likeable_type: 'Activity', likeable_id: @activity.id}
      response.should be_success
      parsed = JSON.parse response.body
      parsed['likeable_type'].should eq('Activity')
      parsed['likeable_id'].should eq(@activity.id)
      parsed['user_id'].should eq(@user.id)
    end
  end

  describe 'DELETE #destroy' do
    include Docs::V0::Likes::Destroy
    # DELETE /api/v0/likes
    it 'should delete a like', :dox do
      @like = Fabricate :like, id:9999, likeable_id: 'Activity', likeable_id: @activity.id, user_id: @user.id
      delete :destroy, params: {id: @like.id}
      response.should be_success
      parsed = JSON.parse response.body
      parsed['likeable_type'].should eq('Activity')
      parsed['likeable_id'].should eq(@activity.id)
      parsed['user_id'].should eq(@user.id)
    end
  end
end
