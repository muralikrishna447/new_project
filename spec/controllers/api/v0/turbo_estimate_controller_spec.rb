require 'spec_helper'

describe Api::V0::TurboEstimateController, :focus => true do
    steak_guide_id = '2MH313EsysIOwGcMooSSkk'
    
    def sign_in_user
        @user = Fabricate :user, name: 'Test User', email: 'admin@chefsteps.com'
        sign_in @user
        controller.request.env['HTTP_AUTHORIZATION'] = @user.valid_website_auth_token.to_jwt 
    end

    describe 'SHOW' do
        it "should respond with an estimate result" do
            sign_in_user
            get :show, {
                guide_id: steak_guide_id,
                set_point: 60,
                thickness_mm: 25.4,
                weight_g: 225,
            }
            response.should be_success
            parsed = JSON.parse response.body
            parsed['top_20_cook_time'].should be_kind_of(Integer)
            parsed['bottom_20_cook_time'].should be_kind_of(Integer)
            parsed['protein_formula'].should eq 'steak'
        end
        
        it "should respond with 401 if user is not logged in" do
            get :show, {
                guide_id: steak_guide_id,
                set_point: 60,
                thickness_mm: 25.4,
                weight_g: 225,
            }
            parsed = JSON.parse response.body
            parsed['status'].should eq 401
        end
        
        it "should respond with status 401 with a message if missing parameters" do
            sign_in_user
            get :show, {
                guide_id: steak_guide_id,
                # set_point: 60,
                thickness_mm: 25.4,
                weight_g: 225,
            }
            parsed = JSON.parse response.body
            parsed['message'].should eq 'missing set_point'
        end
        
        it "should respond with status 401 with a message if guide not supported" do
            sign_in_user
            get :show, {
                guide_id: 'some-other-guide',
                set_point: 60,
                thickness_mm: 25.4,
                weight_g: 225,
            }
            parsed = JSON.parse response.body
            parsed['message'].should eq 'no corresponding estimate formula for guide_id: some-other-guide'
        end
    end

end
