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

  context 'group_name' do

    # Events that should show up in the stream

    it 'returns a comment received item when a user comments' do
      @user2 = Fabricate :user, name: 'Tester 2'
      @comment = Fabricate :comment, content: 'Comment 1 content', commentable: @upload, user: @user2
      @comment_event = Fabricate :event, trackable: @comment, action: 'received_create', user: @user
      @user.events.stream.keys.first[1].should == "Comment_#{@comment.id}_received_create_Upload_#{@upload.id}"
    end

    it 'returns a like received item when a user receives a like an object' do
      @user2 = Fabricate :user, name: 'Tester 2'
      @like = Fabricate :like, likeable: @upload, user: @user2
      @like_event = Fabricate :event, trackable: @like, action: 'received_create', user: @user
      @user.events.stream.keys.first[1].should == "Like_received_create_Upload_#{@upload.id}"
    end

    # Events that should NOT show up in the stream

    it 'does not return a comment create item when a user comments' do
      @comment = Fabricate :comment, content: 'Comment 1 content', commentable: @upload, user: @user
      @comment_event = Fabricate :event, trackable: @comment, action: 'create', user: @user
      @user.events.stream.keys.length.should == 0
    end

    it 'does not return a course enrolled item when a user enrolls into a course' do
      @course = Fabricate :course, title: 'Test Course', description: 'Course description'
      @course_event = Fabricate :event, trackable: @course, action: 'enroll', user: @user
      @user.events.stream.keys.length.should == 0
    end

    it 'does not return a like create item when a user likes an object' do
      @like = Fabricate :like, likeable: @upload, user: @user
      @like_event = Fabricate :event, trackable: @like, action: 'create', user: @user
      @user.events.stream.keys.length.should == 0
    end

    it 'does not return an upload create item when a user uploads a photo' do
      @upload_event = Fabricate :event, trackable: @upload, action: 'create', user: @user
      @user.events.stream.keys.length.should == 0
    end
  end
end
