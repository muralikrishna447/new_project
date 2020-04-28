require 'spec_helper'

feature 'timeline' do

  before :each do
    @activity = Fabricate :activity, title: 'A recipe'
    @upload = Fabricate :upload, title: 'My awesome Lamb Burger', notes: 'This is a story of the greatest lamb burger ever.', activity_id: @activity.id
    @user = Fabricate :user, name: 'Test User', email: 'test@test.com', premium_member: false
  end

  scenario 'liking a published activity shows up in timeline' do
    @published = Fabricate :activity, title: 'Published Activity', published: true
    @like = Fabricate :like, likeable: @published, user: @user
    @event = Fabricate :event, trackable: @like, action: 'create', user: @user
    visit user_profile_path(@user)
    expect(page).to have_content 'liked Published Activity'
  end

  scenario 'liking an unpublished activity does not show up in timeline' do
    @published = Fabricate :activity, title: 'Published Activity', published: false
    @like = Fabricate :like, likeable: @published, user: @user
    @event = Fabricate :event, trackable: @like, action: 'create', user: @user
    visit user_profile_path(@user)
    expect(page).to_not have_content 'liked Published Activity'
  end

  scenario 'enrolling into a published course shows up in timeline', pending: true do
    fail
  end

  scenario 'enrolling into a unpublished courses does not show up in timeline', pending: true do
    fail
  end

end