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
    @user_entries = @user.joule_cook_history_items
    sign_in @user
    controller.request.env['HTTP_AUTHORIZATION'] = @user.valid_website_auth_token.to_jwt
  end
  
  def fabricate_unique_cook_history_item
    @history_item = Fabricate :joule_cook_history_item,
      user_id: @user.id,
      idempotency_id: SecureRandom.uuid,
      cook_id: SecureRandom.uuid
  end
  
  # GET /api/v0/cook_history
  it "should respond with an array of a user's cook history items" do
    fabricate_unique_cook_history_item
    get :index
    response.should be_success
    parsed = JSON.parse response.body
    parsed["cookHistory"].is_a?(Array)
    parsed["cookHistory"].first["externalId"].should == @history_item.external_id
  end
  
  
  # GET /api/v0/cook_history
  it "should paginate with 20 results in the first page" do
    
    21.times do |index|
      Fabricate :joule_cook_history_item,
        user_id: @user.id,
        idempotency_id: SecureRandom.uuid,
        cook_id: index
    end
    
    get :index
    
    response.should be_success
    parsed = JSON.parse response.body
    parsed["cookHistory"].length.should == 20
  end
  
  # GET /api/v0/cook_history
  it "should collapse cook history entries with non-unique cook_ids" do
    10.times do |index|
      Fabricate :joule_cook_history_item,
        user_id: @user.id,
        idempotency_id: SecureRandom.uuid,
        cook_id: index,
        timer_id: "old"
    end
    
    10.times do |index|
      Fabricate :joule_cook_history_item,
        user_id: @user.id,
        idempotency_id: SecureRandom.uuid,
        cook_id: index,
        timer_id: "new"
    end
    
    get :index
    
    response.should be_success
    parsed = JSON.parse response.body
    parsed["cookHistory"].length.should == 10
    last_entry = parsed["cookHistory"].last
    last_entry['program']['programMetadata']['timerId'].should == 'new'
  end
  
  # GET /api/v0/cook_history
  it "should limit results to page size" do
    
    22.times do |index|
      Fabricate :joule_cook_history_item,
        user_id: @user.id,
        idempotency_id: SecureRandom.uuid,
        cook_id: index
    end
    
    get :index
    
    response.should be_success
    parsed = JSON.parse response.body
    parsed["cookHistory"].length.should == 20
  end
  
  # GET /api/v0/cook_history
  it "should limit results to page size when duplicates exist" do
    
    # Create 10 unique entries
    10.times do |index|
      Fabricate :joule_cook_history_item,
        user_id: @user.id,
        idempotency_id: SecureRandom.uuid,
        cook_id: index
    end
    
    # Create 10 non-unique entries and 10 unique entries
    20.times do |index|
      Fabricate :joule_cook_history_item,
        user_id: @user.id,
        idempotency_id: SecureRandom.uuid,
        cook_id: index
    end
    
    get :index
    
    response.should be_success
    parsed = JSON.parse response.body
    parsed["cookHistory"].length.should == 20
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
    fabricate_unique_cook_history_item
    5.times do
      post :create, { cook_history: cook_history_params }
      response.should be_success
    end
    @user_entries.length.should == 2
  end
  
  # DELETE /api/v0/cook_history
  it 'should delete a Cook History Item' do
    fabricate_unique_cook_history_item
    delete :destroy, id: @history_item.external_id
    response.should be_success
    @user_entries.exists?(@history_item.id).should == false
  end
  
  # DELETE /api/v0/cook_history
  it 'should delete all entries with the same cook_id as the entry specified' do
    duplicate_1 = Fabricate :joule_cook_history_item,
      user_id: @user.id,
      idempotency_id: SecureRandom.uuid,
      cook_id: 'duplicate'
    duplicate_2 = Fabricate :joule_cook_history_item,
      user_id: @user.id,
      idempotency_id: SecureRandom.uuid,
      cook_id: 'duplicate'
    unique = Fabricate :joule_cook_history_item,
      user_id: @user.id,
      idempotency_id: SecureRandom.uuid,
      cook_id: 'unique'
      
    delete :destroy, id: duplicate_1.external_id
    
    response.should be_success
    
    @user_entries.exists?(duplicate_1.id).should == false
    @user_entries.exists?(duplicate_2.id).should == false
    @user_entries.exists?(unique.id).should == true
  end

end
