require 'spec_helper'

feature 'courses' do
  before :each do
    activity_1 = Fabricate :activity, title: 'Activity 1', published: true
    activity_2 = Fabricate :activity, title: 'Activity 2', published: true
    activity_3 = Fabricate :activity, title: 'Activity 3', published: true
    course = Fabricate :course, title: 'Spherification'
    inclusion_1 = Fabricate :inclusion, course_id: course.id, activity_id: activity_1.id
    inclusion_1 = Fabricate :inclusion, course_id: course.id, activity_id: activity_2.id
    inclusion_1 = Fabricate :inclusion, course_id: course.id, activity_id: activity_3.id
    bio_chris = Fabricate :copy, location: 'instructor-chris', copy: 'chris'
    bio_grant = Fabricate :copy, location: 'instructor-grant', copy: 'grant'
  end
  # scenario 'renders spherification template for spherification course' do
  #   spherification = Fabricate :course, title: 'spherification', published: true
  #   visit course_path(spherification)
  #   page should render_template 'spherification'
  # end

  # scenario 'renders assignments when visiting a course activity with assignments' do
  #   activity_1 = Fabricate :activity, title: 'Activity 1', published: true
  #   activity_2 = Fabricate :activity, title: 'Activity 2', published: true
  #   activity_3 = Fabricate :activity, title: 'Activity 3', published: true
  #   assignment_1 = Fabricate :assignment, activity_id: activity_1.id, child_activity: activity_2.id
  #   assignment_2 = Fabricate :assignment, activity_id: activity_1.id, child_activity: activity_3.id
  #   course = Fabricate :course
  #   inclusion_1 = Fabricate :inclusion, course_id: course.id, activity_id: activity_1.id
  #   inclusion_1 = Fabricate :inclusion, course_id: course.id, activity_id: activity_2.id
  #   inclusion_1 = Fabricate :inclusion, course_id: course.id, activity_id: activity_3.id
  #   visit [course, activity_1]
  #   page should have_content('Activity 2')
  #   page should have_content('Activity 3')
  # end

  scenario 'shows options to create or sign in when user is not logged in' do
    course = Course.where(title: 'Spherification').first
    visit course_path(course, spherification: 'spheres_c')
    find_link('Enroll').visible?

  end
end