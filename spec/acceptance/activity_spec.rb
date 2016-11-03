require 'spec_helper'

feature 'activities', :js => true, pending: true do
  scenario "steps render when a youtube_id is inputed" do
    activity = Fabricate(:activity, title: 'test', published: true)
    step = Fabricate(:step, activity_id: activity.id, title: 'hello', youtube_id: 'REk30BRVtgE')
    visit activity_path(activity)
    page.should have_content('hello')
    within('div.step') do
      page.should have_css('.video-container')
    end
  end

end

# NOTE: these tests were added in order to test the full Rails app,
# including middleware

describe "Activities" do
  before :each do
    # use the in-app rack driver, don't care about Javascript
    Capybara.current_driver = :anonymous_rack_test
    @activity_published = Fabricate :activity, title: 'Activity Published', published: true, id: 1
    @activity_published.steps << Fabricate(:step, activity_id: @activity_published.id, title: 'hello', youtube_id: 'REk30BRVtgE')
  end

  it "can anonymously list all activities" do
    visit('/api/v0/activities')
    activities = JSON.parse page.html
    puts activities
    expect(activities.length).to eq 1
  end

  it "can anonymously fetch a published activity" do
    visit('/api/v0/activities/activity-published')
    activity = JSON.parse page.html
    expect(activity['title']).to eq 'Activity Published'
    puts activity
  end

end
