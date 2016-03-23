require 'spec_helper'

describe Event do
  before(:each) do
    @user = Fabricate :user, name: 'Bob Smith'
    @activity1 = Fabricate :activity, title: 'Hello activity 1', published: true
    @activity2 = Fabricate :activity, title: 'Hello activity 2', published: true
    @event1 = Fabricate :event, trackable: @activity1, action: 'show', user: @user
    @event2 = Fabricate :event, trackable: @activity2, action: 'show', user: @user
    @upload = Fabricate :upload, title: 'Upload 1', notes: 'Upload 1 note', image_id: 'hello', user: @user
  end

  it 'returns events scoped by a trackable type and action' do
    Event.scoped_by('Activity', 'show').count.should == 2
  end

  context 'published events' do

    # Events that should show up in the stream

    it 'returns a course enroll item', pending: true do

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

    it 'when enrolled course is unpublished', pending: true do
      # @unpublished = Fabricate :course, title: 'Unpublished', published: false
      # @event = Fabricate :event, trackable: @unpublished, action: 'enroll', user: @user
      # @event.save_group_type_and_group_name
      # @event.published.should == false
    end
  end

end
