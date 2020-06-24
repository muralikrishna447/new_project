require 'spec_helper'

describe LikesController do
  before do
    @user = Fabricate :user, name: 'Bob Smith', email: 'test@test.com'
    sign_in @user
  end

  context 'Liking an activity' do
    it 'updates like count in Algolia' do
      @activity = Fabricate :activity, title: 'Blahh!!'
      @user = Fabricate :user, name: 'Bob Smith'
      post :create, params: {likeable_type: "Activity", likeable_id: @activity.id, user: @user}
      WebMock.assert_requested(:put, "https://jgv2odt81s.algolia.net/1/indexes/ChefSteps_test/#{@activity.id}") { |req| JSON.parse(req.body)['likes_count'] == 1 }
    end
  end
end
