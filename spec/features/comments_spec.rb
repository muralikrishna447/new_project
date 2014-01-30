require 'spec_helper'

feature 'comments' do

  before :each do
    @activity = Fabricate :activity, title: 'A recipe'
    @user = Fabricate :user, name: 'Test User', email: 'test@test.com'
    @upload = Fabricate :upload, title: 'My awesome Lamb Burger', notes: 'This is a story of the greatest lamb burger ever.', activity_id: @activity.id, user_id: @user.id
  end

  scenario 'upload comments can be viewed' do
    5.times.each_with_index do |value,index|
      comment = @upload.comments.create! content: "Hello#{index}", user_id: @user.id
    end
    puts @upload.inspect
    visit upload_path(@upload)
  end

end