require 'spec_helper'

describe Like do
  context 'Liking an activity' do
    it 'updates like count in Algolia' do
      @activity = Fabricate :activity, title: 'Blahh!!'
      WebMock.reset!
      @user = Fabricate :user, name: 'Bob Smith'
      @like = Fabricate :like, likeable: @activity, user: @user
    end
  end
end
