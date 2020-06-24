require 'spec_helper'

describe EventsController do
  describe 'POST create' do

    before do
      @user = Fabricate :user, name: 'Bob Smith', email: 'test@test.com'
      @activity = Fabricate :activity, title: 'Test Activity'
      @like = Fabricate :like, likeable: @activity, user: @user
    end

    it 'creates an event if user signed in' do
      sign_in @user
      post :create, params: {event: {trackable_id: @activity.id, trackable_type: @activity.class.to_s, action: 'show'}}
      expect(response).to be_success
    end

    it 'does not create an event if user is not signed in' do
      post :create, params: {event: {trackable_id: @activity.id, trackable_type: @activity.class.to_s, action: 'show'}}
      expect(response.status).to eq(302)
    end

  end
end