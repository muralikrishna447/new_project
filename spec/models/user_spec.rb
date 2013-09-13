require 'spec_helper'

describe User, '#profile_complete?' do
  let(:user) { Fabricate.build(:user) }
  it 'is incomplete on new user' do
    user.profile_complete?.should_not be
  end

  it 'is complete if chef_type is specified' do
    user.chef_type = 'professional_chef'
    user.profile_complete?.should be
  end

  it 'returns viewed activities within a course' do
    course = Fabricate :course
    activity_1 = Fabricate :activity, title: 'Activity 1', published: true
    activity_2 = Fabricate :activity, title: 'Activity 2', published: true
    activity_3 = Fabricate :activity, title: 'Activity 3', published: true
    activity_4 = Fabricate :activity, title: 'Activity 4', published: false
    inclusion_1 = Fabricate :inclusion, course_id: course.id, activity_id: activity_1.id
    inclusion_2 = Fabricate :inclusion, course_id: course.id, activity_id: activity_2.id
    inclusion_3 = Fabricate :inclusion, course_id: course.id, activity_id: activity_3.id
    inclusion_4 = Fabricate :inclusion, course_id: course.id, activity_id: activity_4.id
    event_1 = Fabricate :event, trackable: activity_1, action: 'show', user: user
    event_2 = Fabricate :event, trackable: activity_2, action: 'show', user: user
    user.viewed_activities_in_course(course).count.should == 2
    user.viewed_activities_in_course(course).should include(activity_1)
    user.viewed_activities_in_course(course).should include(activity_2)
    user.viewed_activities_in_course(course).should_not include(activity_3)
    user.viewed_activities_in_course(course).should_not include(activity_4)
  end
end
