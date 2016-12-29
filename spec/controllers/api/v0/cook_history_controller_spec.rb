require 'spec_helper'

describe Api::V0::CookHistoryController do

  joule_program_data = {
    "set_point"=>58,
     "cook_time"=>64800,
     "holding_temperature"=>58,
     "program_type"=>"AUTOMATIC",
     "program_id"=>"65lArYOHsseoMseoAoyySY",
     "guide_id"=>"48FZLHVtTqauC4qK8YskY",
     "cook_id"=>"9c9f6e14f6ac48479eeab391d4376b77",
     "timer_id"=>"6B9gdJ14cMsMI4W6YWyIWY"
   }
   
   cook_history_params = {
     history_item_type: 'joule',
     joule_cook_history_program_attributes: joule_program_data
   }

  before :each do
    @user = Fabricate :user, name: 'Test User', email: 'admin@chefsteps.com'
    sign_in @user
    controller.request.env['HTTP_AUTHORIZATION'] = @user.valid_website_auth_token.to_jwt
    @history_item = Fabricate :cook_history_item,  history_item_type: 'joule', 
      joule_cook_history_program_attributes: joule_program_data, user_id: @user.id
  end
  
  it "should respond with an array of a user's cook history items" do
    get :index
    response.should be_success
    parsed = JSON.parse response.body
    parsed["results"].is_a?(Array)
    parsed["results"].first["uuid"].should == @history_item.uuid
  end

  # POST /api/v0/cook_history
  it 'should create a Cook History Item that belongs to authenticated user' do
    post :create, { cook_history: cook_history_params }
    response.should be_success
    parsed = JSON.parse response.body
    CookHistoryItem.find_by_uuid(parsed["uuid"]).user.should == @user
  end

   # DELETE /api/v0/cook_history
   it 'should delete a Cook History Item' do
     delete :destroy, id: @history_item.uuid
     response.should be_success
   end

end
