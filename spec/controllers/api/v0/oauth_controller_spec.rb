require 'spec_helper'

describe Api::V0::OauthTokensController do

  before :each do
    @user = Fabricate :user, id: 100, email: 'johndoe@chefsteps.com', password: '123456', name: 'John Doe', role: 'user'
    @aa = ActorAddress.create_for_user @user, client_metadata: "test"
    @token = 'Bearer ' + @aa.current_token.to_jwt

    @other_user = Fabricate :user, id: 101, email: 'janedoe@chefsteps.com', password: '123456', name: 'Jane Doe', role: 'user'
    @other_aa = ActorAddress.create_for_user @other_user, client_metadata: "test"
    @other_token = 'Bearer ' + @other_aa.current_token.to_jwt

  end

  context 'GET /index' do
    it 'should return a users oauth tokens' do
      request.env['HTTP_AUTHORIZATION'] = @token

      token = "abc"
      service = "ge"

      Fabricate(:oauth_token, service: service, token: token, user_id: @user.id, token_expires_at: Time.now+1.year)

      get :index

      response.code.should == "200"
      result = JSON.parse(response.body)

      result["results"].length.should == 1
      result["status"].should == 200
      result["results"].first["service"].should == service
      result["results"].first["token"].should == token

    end

    it 'should return an empty result if the user has no tokens' do
      request.env['HTTP_AUTHORIZATION'] = @token

      get :index

      response.code.should == "200"
      result = JSON.parse(response.body)

      result["results"].length.should == 0
      result["results"].should == []
      result["status"].should == 200

    end
  end
end
