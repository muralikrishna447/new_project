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

  context 'published events' do

    # Events that should show up in the stream

    it 'returns a comment create item' do
      @user2 = Fabricate :user, name: 'Tester 2'
      @comment = Fabricate :comment, content: 'Comment 1 content', commentable: @upload, user: @user2
      @event = Fabricate :event, trackable: @comment, action: 'create', user: @user2
      @event.save_group_type_and_group_name
      Stream.all_events.first.should == @event
    end

    it 'returns a course enroll item' do
      @course = Fabricate :course, title: 'Test Course', description: 'Course description'
      @event = Fabricate :event, trackable: @course, action: 'enroll', user: @user, published: true
      Stream.all_events.first.should == @event
    end

    it 'returns a like create item' do
      @like = Fabricate :like, likeable: @upload, user: @user
      @event = Fabricate :event, trackable: @like, action: 'create', user: @user, published: true
      Stream.all_events.first.should == @event
    end

    it 'returns a upload create item' do
      @event = Fabricate :event, trackable: @upload, action: 'create', user: @user, published: true
      Stream.all_events.first.should == @event
    end

    it 'returns a vote create item' do
      @poll = Fabricate :poll, title: 'My Test Poll', description: 'This describes the first poll.'
      @poll_item = Fabricate :poll_item, title: 'My Test Poll Item', description: 'This describes the poll item.', poll: @poll
      @vote = Fabricate :vote, votable: @poll_item, user: @user
      @event = Fabricate :event, trackable: @vote, action: 'create', user: @user, published: true
      Stream.all_events.first.should == @event
    end

  end

  context 'event set as unpublished' do
    it 'when created activity is unpublished' do
      @unpublished = Fabricate :activity, title: 'Unpublished', published: false
      @event = Fabricate :event, trackable: @unpublished, action: 'create', user: @user
      @event.save_group_type_and_group_name
      @event.published.should == false
    end

    it 'when liked activity is unpublished' do
      @unpublished = Fabricate :activity, title: 'Unpublished', published: false
      @like = Fabricate :like, likeable: @unpublished, user: @user
      @event = Fabricate :event, trackable: @like, action: 'create', user: @user
      @event.save_group_type_and_group_name
      @event.published.should == false
    end

    it 'when enrolled course is unpublished' do
      @unpublished = Fabricate :course, title: 'Unpublished', published: false
      @event = Fabricate :event, trackable: @unpublished, action: 'enroll', user: @user
      @event.save_group_type_and_group_name
      @event.published.should == false
    end
  end

end
