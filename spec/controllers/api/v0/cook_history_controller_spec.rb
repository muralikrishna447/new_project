require 'spec_helper'

describe Api::V0::CookHistoryController do


  cook_history_params = {
    cook_id: "eb10428ed5f24c55988cbd1bf84523d4",
    cook_time: 64800,
    guide_id: "3kXWJim8FqKsC6AOy62M8C",
    idempotency_id: "7095f553-f68e-4e33-9de6-08c6369e0db6",
    program_id: "6yrX59W7oQ82sUE0woWgUS",
    program_type: "AUTOMATIC",
    set_point: 58,
    start_time: 1483999425792,
    started_from: "jouleApp",
    timer_id: "6cVAqvnbbymQOOOKWUGWgS"
  }

  before :each do
    @user = Fabricate :user, name: 'Test User', email: 'admin@chefsteps.com'
    sign_in @user
    controller.request.env['HTTP_AUTHORIZATION'] = @user.valid_website_auth_token.to_jwt
    @history_item = Fabricate :joule_cook_history_item, user_id: @user.id, idempotency_id: SecureRandom.uuid
  end

  # GET /api/v0/cook_history
  it "should respond with an array of a user's cook history items" do
    get :index
    response.should be_success
    parsed = JSON.parse response.body
    parsed["cookHistory"].is_a?(Array)
    parsed["cookHistory"].first["externalId"].should == @history_item.external_id
  end

  # GET /api/v0/cook_history
  it "should paginate with 20 results per page" do

    21.times do
      Fabricate :joule_cook_history_item, user_id: @user.id, idempotency_id: SecureRandom.uuid
    end

    get :index

    response.should be_success
    parsed = JSON.parse response.body
    parsed["cookHistory"].length.should == 20

    get :index, {page: 2}

    response.should be_success
    parsed = JSON.parse response.body
    parsed["cookHistory"].length.should == 2
  end

  # GET /api/v0/cook_history/find_by_guide
  describe 'find_by_guide' do
    before :each do
      @history_item = Fabricate :joule_cook_history_item, user_id: @user.id, guide_id: 'guide1', idempotency_id: SecureRandom.uuid
      @history_item = Fabricate :joule_cook_history_item, user_id: @user.id, guide_id: 'guide2', idempotency_id: SecureRandom.uuid
      @history_item = Fabricate :joule_cook_history_item, user_id: @user.id, guide_id: 'guide1', idempotency_id: SecureRandom.uuid
    end

    it "should error if guide_id isn't specified" do
      get :find_by_guide
      response.code.should == '400'
    end

    it "should find 0 items" do
      get :find_by_guide, guide_id: 'nobody'
      response.should be_success
      parsed = JSON.parse response.body
      parsed["cookHistory"].length.should == 0
    end

    it "should find 2 items" do
      get :find_by_guide, guide_id: 'guide1'
      response.should be_success
      parsed = JSON.parse response.body
      parsed["cookHistory"].length.should == 2
    end

    it "should respect limit" do
      get :find_by_guide, guide_id: 'guide1', limit: 1
      response.should be_success
      parsed = JSON.parse response.body
      parsed["cookHistory"].length.should == 1
    end
  end

  # POST /api/v0/cook_history
  it 'should create a Cook History Item that belongs to authenticated user' do
    post :create, { cook_history: cook_history_params }
    response.should be_success
    parsed = JSON.parse response.body
    JouleCookHistoryItem.find_by_external_id(parsed["externalId"]).user.should == @user
  end

  # POST /api/v0/cook_history
  it 'should not create item with identical user/idempotency_id as existing entry' do
    2.times do
      post :create, { cook_history: cook_history_params }
      response.should be_success
    end
    # 2 since an item has also been created in 'before :each'
    @user.joule_cook_history_items.length.should == 2
  end

   # DELETE /api/v0/cook_history
   it 'should delete a Cook History Item' do
     delete :destroy, id: @history_item.external_id
     response.should be_success
   end

end
