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