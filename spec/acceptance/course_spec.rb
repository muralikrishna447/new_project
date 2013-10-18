require 'spec_helper'

feature 'courses' do
  before :each do
    @user = Fabricate :user, name: 'Test', email: 'test@test.com', password: 'password'
    @activity_1 = Fabricate :activity, title: 'Activity 1', published: true
    @activity_2 = Fabricate :activity, title: 'Activity 2', published: true
    @activity_3 = Fabricate :activity, title: 'Activity 3', published: true
    @course = Fabricate :course, title: 'Spherification', published: true
    @inclusion_1 = Fabricate :inclusion, course_id: @course.id, activity_id: @activity_1.id
    @inclusion_1 = Fabricate :inclusion, course_id: @course.id, activity_id: @activity_2.id
    @inclusion_1 = Fabricate :inclusion, course_id: @course.id, activity_id: @activity_3.id
    @bio_chris = Fabricate :copy, location: 'instructor-chris', copy: 'chris'
    @bio_grant = Fabricate :copy, location: 'instructor-grant', copy: 'grant'
  end

  context 'user not signed in' do

    scenario 'can sign in and enroll' do
      visit course_path(@course)
      within('.signin-and-enroll-section') do
        fill_in 'email', with: @user.email
        fill_in 'password', with: @user.password
        click_button('Sign In and Enroll')
      end
      expect(@user.enrollments.first.enrollable.title).to eq('Spherification')
    end

    scenario 'can create account and enroll' do
      visit course_path(@course)
      within('.signup-and-enroll-section') do
        fill_in 'name', with: 'test1'
        fill_in 'email', with: 'test1@test1.com'
        fill_in 'password', with: 'password1'
        click_button('Create Account and Enroll')
      end
      user = User.last
      expect(user.email).to eq('test1@test1.com')
      expect(user.enrollments.first.enrollable.title).to eq('Spherification')
    end
  end
end