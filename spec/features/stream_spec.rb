require 'spec_helper'

feature 'stream' do

  context 'item created' do
    before :each do
      @assembly = Fabricate :assembly, title: 'Test Course', description: 'This is a test course.', published: true
      @activity = Fabricate :activity, title: 'Test Activity', published: true
      @inclusion = Fabricate :assembly_inclusion, assembly_id: @assembly.id, includable: @activity
      @upload = Fabricate :upload, title: 'Test Upload', notes: 'This is a test upload.', activity_id: @activity.id
      @poll = Fabricate :poll, title: 'Test Poll', description: 'Test Poll description'
      @poll_item = Fabricate :poll_item, title: 'Test Poll Item', description: 'Test Poll Item description'
      @user = Fabricate :user, name: 'Test User', email: 'test@test.com', password: 'password'

      visit '/'
      click_link('Sign in')
      current_path.should == sign_in_path

      fill_in 'user_email', with: 'test@test.com'
      fill_in 'user_password', with: 'password'
      click_button 'Sign in'
    end

    scenario 'when user comments' do

      @comment = Fabricate :comment, commentable: @upload, user: @user
      visit '/streams'
      # puts page.body
      # expect(page).to have_content 'Comment'
    end
  end

  # scenario 'votes show up in timeline' do
  #   @vote = Fabricate :vote, votable: @poll_item, user: @user
  #   @event = Fabricate :event, trackable: @vote, action: 'create', user: @user
  #   visit user_profile_path(@user)
  #   expect(page).to have_content 'voted for Test Poll Item'
  # end

  # scenario 'undo vote does not show up in timeline' do
  #   @vote = Fabricate :vote, votable: @poll_item, user: @user
  #   @event = Fabricate :event, trackable: @vote, action: 'create', user: @user
  #   @vote.destroy
  #   visit user_profile_path(@user)
  #   expect(page).to_not have_content 'voted for Test Poll Item'
  # end

  # scenario 'liking a published activity shows up in timeline' do
  #   @published = Fabricate :activity, title: 'Published Activity', published: true
  #   @like = Fabricate :like, likeable: @published, user: @user
  #   @event = Fabricate :event, trackable: @like, action: 'create', user: @user
  #   visit user_profile_path(@user)
  #   expect(page).to have_content 'liked Published Activity'
  # end

  # scenario 'liking an unpublished activity does not show up in timeline' do
  #   @published = Fabricate :activity, title: 'Published Activity', published: false
  #   @like = Fabricate :like, likeable: @published, user: @user
  #   @event = Fabricate :event, trackable: @like, action: 'create', user: @user
  #   visit user_profile_path(@user)
  #   expect(page).to_not have_content 'liked Published Activity'
  # end

  # scenario 'enrolling into a published course shows up in timeline' do
  #   @published = Fabricate :course, title: 'Published Course', published: true
  #   @assembly_activity = Fabricate :activity, title: 'First activity', published: true
  #   @inclusion = Fabricate :inclusion, course_id: @published.id, activity_id: @assembly_activity.id
  #   @event = Fabricate :event, trackable: @published, action: 'enroll', user: @user
  #   visit user_profile_path(@user)
  #   expect(page).to have_content 'enrolled into the Published Course'
  # end

  # scenario 'enrolling into a unpublished courses does not show up in timeline' do
  #   @unpublished = Fabricate :course, title: 'Unpublished Course', published: false
  #   @assembly_activity = Fabricate :activity, title: 'First activity', published: true
  #   @inclusion = Fabricate :inclusion, course_id: @unpublished.id, activity_id: @assembly_activity.id
  #   @event = Fabricate :event, trackable: @unpublished, action: 'enroll', user: @user
  #   visit user_profile_path(@user)
  #   expect(page).to_not have_content 'enrolled into the Unpublished Course'
  # end

end