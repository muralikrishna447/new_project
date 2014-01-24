require 'spec_helper'

describe UserSurveysController do
  describe 'POST update' do

    before do
      @user = Fabricate :user, name: 'Bob Smith', email: 'test@test.com'
    end

    it 'updates a user with survey results' do
      sign_in @user
      post :update, survey_results: {data: 'Some Random JSON'}
      expect(response).to be_success
      expect(response.body).to eq("{\"data\":\"Some Random JSON\"}")
    end

  end
end