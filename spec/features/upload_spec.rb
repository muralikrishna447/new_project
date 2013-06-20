require 'spec_helper'

feature 'uploads', js: true do

  before :each do
    @activity_1 = Fabricate :activity, title: 'Activity', description: 'hello', published: true
  end
  scenario 'user can upload a photo for activities' do
    visit activity_path(@activity_1)
    find_link('UPLOAD YOUR OWN').click
    find('#upload-user-creation').visible?
  end
end