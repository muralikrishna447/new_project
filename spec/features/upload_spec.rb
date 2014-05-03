require 'spec_helper'

feature 'uploads' do

  before :each do
    @activity_1 = Fabricate :activity, title: 'Activity', description: 'hello', published: true
  end

  scenario 'user can upload a photo for activities' do
    visit activity_path(@activity_1)
    find_link('ADD YOUR OWN').visible?
    find('#upload-user-creation').visible?
  end

end