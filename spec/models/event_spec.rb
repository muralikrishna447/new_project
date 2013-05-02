require 'spec_helper'

describe Event do
  before(:each) do
    user = Fabricate :user, name: 'Bob Smith'
    activity1 = Fabricate :activity, title: 'Hello activity 1', published: true
    activity2 = Fabricate :activity, title: 'Hello activity 2', published: true
    quiz = Fabricate :quiz
    event1 = Fabricate :event, trackable: activity1, action: 'show', user: user
    event2 = Fabricate :event, trackable: activity2, action: 'show', user: user
    event3 = Fabricate :event, trackable: quiz, action: 'show', user: user
  end

  it 'returns events scoped by a trackable type and action' do

    # expect(Event.scoped_by('Activity', 'show').count).to eq(2)
    Event.scoped_by('Activity', 'show').count.should == 2
  end
end
