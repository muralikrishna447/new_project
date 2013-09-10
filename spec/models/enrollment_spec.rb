require 'spec_helper'

describe Enrollment do
  before :each do
    @user = Fabricate :user, email: 'test@test.com', name: 'Test User'
    @course = Fabricate :course, title: 'Test Course'
    @assembly = Fabricate :assembly, title: 'Test Assembly'
  end
  
  it 'should return a course object when a user enrolls into a course' do
    enrollment = Fabricate :enrollment, user: @user, enrollable: @course
    expect(enrollment.enrollable).to be_an_instance_of(Course)
  end

  it 'should return a course object when a user enrolls into a course' do
    enrollment = Fabricate :enrollment, user: @user, enrollable: @assembly
    expect(enrollment.enrollable).to be_an_instance_of(Assembly)
  end

  it 'should not allow a user to enroll into the same course twice' do
    enrollment1 = Fabricate :enrollment, user: @user, enrollable: @assembly
    enrollment2 = Fabricate.build(:enrollment, user: @user, enrollable: @assembly)
    enrollment1.should be_valid
    enrollment2.should_not be_valid
  end
end
