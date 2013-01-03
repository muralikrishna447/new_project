require 'spec_helper'

describe Course do
  let!(:course_last) { Fabricate(:course, course_order_position: 2, published: true) }
  let!(:course_first) { Fabricate(:course, course_order_position: 0, published: true) }
  let!(:course_middle) { Fabricate(:course, course_order_position: 1, published: true) }
  let!(:course_private) { Fabricate(:course, course_order_position: 3) }

  let!(:activity0) { Fabricate(:activity, id: 99, nesting_level: 0, published: true) }
  let!(:activity1) { Fabricate(:activity, id: 100, published: true) }
  let!(:activity2) { Fabricate(:activity, id: 200, published: false) }
  let!(:activity3) { Fabricate(:activity, id: 300, published: true) }
  let!(:activity4) { Fabricate(:activity, id: 400, nesting_level: 0, published: true) }
  let!(:activity5) { Fabricate(:activity, id: 500, published: true) }


  it "creates 4 courses and reorders them" do
    Course.all.collect.should have(4).course
    Course.ordered.all.should == [course_first, course_middle, course_last, course_private]
    course_last.update_attribute :course_order_position, 0
    Course.ordered.all.should == [course_last, course_first, course_middle, course_private]
  end

  it "adds 3 activities and messes with order" do
    course_first.update_activities([100, 200, 300])
    course_first.first_published_activity.should == activity1
    course_first.update_activities([300, 200, 100])
    course_first.first_published_activity.should == activity3
    course_first.next_published_activity(activity3).should == activity1
    course_first.prev_published_activity(activity3).should == nil
    course_first.next_published_activity(activity1).should == nil
    course_first.prev_published_activity(activity1).should == activity3
  end

  it "handles modules" do
    course_first.update_activities([99, 100, 200, 300, 400, 500])
    course_first.moduled_activities.should have(2).array
  end
end
