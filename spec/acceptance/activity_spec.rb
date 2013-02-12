require 'spec_helper'

feature 'activities', :js => true do
  scenario "steps render when a youtube_id is inputed" do
    step = Fabricate(:step, title: 'hello', youtube_id: 'REk30BRVtgE')
    activity = Fabricate(:activity, title: 'test', published: true) { step }
    recipe_activity_step = Fabricate(:activity_recipe_step, activity_id: activity.id, step_id: step.id)
    visit activity_path(activity)
    page.should have_content('hello')
    within('div.step') do
      page.should have_css('.video-container')
    end
  end
  
end