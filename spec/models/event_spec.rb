require 'spec_helper'

describe Event do
  before(:each) do
    @user = Fabricate :user, name: 'Bob Smith'
    @activity1 = Fabricate :activity, title: 'Hello activity 1', published: true
    @activity2 = Fabricate :activity, title: 'Hello activity 2', published: true
    @quiz = Fabricate :quiz
    @event1 = Fabricate :event, trackable: @activity1, action: 'show', user: @user
    @event2 = Fabricate :event, trackable: @activity2, action: 'show', user: @user
    @event3 = Fabricate :event, trackable: @quiz, action: 'show', user: @user
    @upload = Fabricate :upload, title: 'Upload 1', notes: 'Upload 1 note', image_id: 'hello', user: @user
  end

  it 'returns events scoped by a trackable type and action' do
    Event.scoped_by('Activity', 'show').count.should == 2
    Event.scoped_by('Quiz', 'show').count.should == 1
  end

  context 'stream' do

    it 'returns a comment stream item when a user comments' do
      @comment = Fabricate :comment, content: 'Comment 1 content', commentable: @upload, user: @user
      @comment_event = Fabricate :event, trackable: @comment, action: 'create', user: @user
      @user.events.timeline.stream[0][1].group_name.should == "Comment_#{@comment.id}_create_Upload_#{@upload.id}"
    end
  end
end
