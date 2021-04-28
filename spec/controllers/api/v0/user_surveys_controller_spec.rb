require 'spec_helper'

describe Api::V0::UserSurveysController do
  include Docs::V0::UserSurveys::Api

  context 'authenticated user is user role', :dox do
    before :each do
      @user = Fabricate :user, name: 'Normal User', email: 'user@chefsteps.com', role: 'user'
      sign_in @user
      controller.request.env['HTTP_AUTHORIZATION'] = @user.valid_website_auth_token.to_jwt
    end

    describe 'POST #create' do
      include Docs::V0::UserSurveys::Create
      # POST /api/v0/user_surveys
      it 'updates a user with survey results' do
        post :create, params: {survey_results: {data: 'Some Random Data'}}
        expect(response).to be_success
        expect(response.body).to eq("{\"data\":\"Some Random Data\"}")
      end
    end
  end
end
