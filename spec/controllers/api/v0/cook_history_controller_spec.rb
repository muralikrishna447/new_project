require 'spec_helper'

describe Api::V0::CookHistoryController do

  def create_cook_entry (program_type: 'AUTOMATIC', is_guided: true)
    
    entry = {
      cook_id: "eb10428ed5f24c55988cbd1bf84523d4",
      cook_time: 64800,
      idempotency_id: 'ab10428ed5f24d55988cbd1bf84523d3',
      program_type: program_type,
      set_point: 58,
      start_time: 1483999425792,
      started_from: "jouleApp",
      program_id: nil,
      guide_id: nil,
      timer_id: nil
    }
    
    if is_guided
      entry[:guide_id] = "3kXWJim8FqKsC6AOy62M8C"
      entry[:program_id] = "6yrX59W7oQ82sUE0woWgUS"
      entry[:timer_id] = "6cVAqvnbbymQOOOKWUGWgS"
    end
      
    return entry
  end

  before :each do
    @user = Fabricate :user, name: 'Test User', email: 'admin@chefsteps.com'
    @user_entries = @user.joule_cook_history_items
    sign_in @user
    controller.request.env['HTTP_AUTHORIZATION'] = @user.valid_website_auth_token.to_jwt
  end
  
  def fabricate_unique_cook_history_item(turbo_cook_state = nil)
    @history_item = Fabricate :joule_cook_history_item,
      user_id: @user.id,
      idempotency_id: SecureRandom.uuid,
      cook_id: SecureRandom.uuid,
      turbo_cook_state: turbo_cook_state
  end

  # GET /api/v0/cook_history
  it "should respond with an array of a user's cook history items" do
    fabricate_unique_cook_history_item
    get :index
    response.should be_success
    parsed = JSON.parse response.body
    parsed["cookHistory"].is_a?(Array)
    parsed["cookHistory"].first["externalId"].should == @history_item.external_id
    parsed["cookHistory"].first["turboCookState"].should be_nil
  end

  # GET /api/v0/cook_history
  it "should respond with an array of a user's cook history items" do
    fabricate_unique_cook_history_item('TURBO_ENABLED')
    get :index
    response.should be_success
    parsed = JSON.parse response.body
    parsed["cookHistory"].is_a?(Array)
    parsed["cookHistory"].first["program"]["turboCookState"].should == 'TURBO_ENABLED'
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
  describe 'create' do
    it 'should create a Cook History Item that belongs to authenticated user' do
      post :create, { cook_history: create_cook_entry() }
      response.should be_success
      parsed = JSON.parse response.body
      JouleCookHistoryItem.find_by_external_id(parsed["externalId"]).user.should == @user
      parsed['turboCookState'] = nil
    end

    it 'should not create item with identical user/idempotency_id as existing entry' do
      fabricate_unique_cook_history_item
      5.times do
        post :create, { cook_history: create_cook_entry() }
        response.should be_success
      end
      @user_entries.length.should == 2
    end

    it 'should create a Cook History Item with turbo_cook_state' do
      payload = create_cook_entry()
      payload[:turbo_cook_state] = 'TURBO_ENABLED'
      post :create, { cook_history: create_cook_entry() }
      response.should be_success
      parsed = JSON.parse response.body
      parsed['turboCookState'] = 'TURBO_ENABLED'
    end
    
    describe 'validation' do
      UNPROCESSABLE_ENTITY_STATUS = 422
      it 'should succeed when valid: guided and AUTOMATIC' do
        create_params = create_cook_entry(program_type: 'AUTOMATIC', is_guided: true)
        post :create, { cook_history: create_params }
        response.should be_success
      end
      
      it 'should fail when missing program_id or timer_id: guided' do
        create_params = create_cook_entry(program_type: 'AUTOMATIC', is_guided: true)
        create_params[:program_id] = nil
        post :create, { cook_history: create_params }
        response.status.should == UNPROCESSABLE_ENTITY_STATUS
        
        create_params = create_cook_entry(program_type: 'AUTOMATIC', is_guided: true)
        create_params[:timer_id] = nil
        post :create, { cook_history: create_params }
        response.status.should == UNPROCESSABLE_ENTITY_STATUS
      end
      
      it 'should succeed when valid: non-guided and AUTOMATIC' do
        create_params = create_cook_entry(program_type: 'AUTOMATIC', is_guided: false)
        post :create, { cook_history: create_params }
        response.should be_success
      end
    end
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
