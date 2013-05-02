require 'spec_helper'

describe Course do
  let!(:course_last) { Fabricate(:course, course_order_position: 2, published: true) }
  let!(:course_first) { Fabricate(:course, course_order_position: 0, published: true) }
  let!(:course_middle) { Fabricate(:course, course_order_position: 1, published: true) }
  let!(:course_private) { Fabricate(:course, course_order_position: 3) }

  let!(:activity0) { Fabricate(:activity, id: 99,  published: true) }
  let!(:activity1) { Fabricate(:activity, id: 100, published: true) }
  let!(:activity2) { Fabricate(:activity, id: 200, published: false) }
  let!(:activity3) { Fabricate(:activity, id: 300, published: true) }
  let!(:activity4) { Fabricate(:activity, id: 400, published: true) }
  let!(:activity5) { Fabricate(:activity, id: 500, published: true) }


  it "creates 4 courses and reorders them" do
    Course.all.collect.should have(4).course
    Course.ordered.all.should == [course_first, course_middle, course_last, course_private]
    course_last.update_attribute :course_order_position, 0
    Course.ordered.all.should == [course_last, course_first, course_middle, course_private]
  end

  it "adds 3 activities" do
    c = course_first
    c.update_activities([[100, 0, ""], [200, 1, ""], [300, 1, ""]])
    c.activities.count.should == 3
    c.first_published_activity.should == activity3
  end

  it "adds a more complex hierarchy"do
    c = course_first
    c.update_activities([[500, 0, ""], [300, 1, ""], [200, 0, ""], [100, 1, ""], [400, 2, ""]])
    c.first_published_activity.should == activity3
    c.next_published_activity(activity3).should == activity1
    c.prev_published_activity(activity3).should == nil
    c.next_published_activity(activity4).should == nil
    c.prev_published_activity(activity4).should == activity1
  end

  it "has two courses that share an activity" do
    c1 = course_first
    c2 = course_last
    c1.update_activities([[99, 0, ""], [100, 1, ""], [300, 1, ""]])
    c2.update_activities([[99, 0, ""], [100, 1, ""], [400, 1, ""]])
    c1.first_published_activity.should == activity1
    c2.first_published_activity.should == activity1
    c1.next_published_activity(activity1).should == activity3
    c2.next_published_activity(activity1).should == activity4
  end

  it "creates a new module and activity on the fly" do
    c = course_first
    c.update_activities([[99, 0, ""], [100,1, ""], [99999, 1, "Cool Activity Dude"], [300, 1, ""]])
    c.activities.find { |x| x.title == "Cool Activity Dude"}.should_not == nil
    c.activities.find { |x| x.title == "Fork Me"}.should == nil
  end

  it 'returns the parent inclusion for an inclusion' do
    c = course_first
    parent = activity1
    c.update_activities([[99, 0, ''], [100, 0, ''], [200, 1, ''], [300, 1, ''], [400, 1, ''], [500, 0, '']])
    a = c.inclusions.where(activity_id: activity4.id).first
    c.parent_inclusion(a).activity.should == parent
  end

  it 'returns the child inclusions for an inclusion' do
    c = course_first
    activity_ids = [200,300,400]
    c.update_activities([[99, 0, ''], [100, 0, ''], [200, 1, ''], [300, 1, ''], [400, 1, ''], [500, 0, '']])
    parent = c.inclusions.select{|i| i.activity.id == activity1.id}.first
    c.child_inclusions(parent).map{|i| i.activity.id}.should == activity_ids
  end

  it 'returns the next inclusion for an inclusion within a course' do
    c = course_first
    activity_ids = [200,300,400]
    c.update_activities([[99, 0, ''], [100, 0, ''], [200, 1, ''], [300, 1, ''], [400, 1, ''], [500, 0, '']])
    inclusion = c.inclusions.first
    c.next_inclusion(inclusion).activity.id.should == 100
  end

  it 'returns the viewable activites for a course' do
    c = course_first
    activity_ids = [200,300,400]
    c.update_activities([[99, 0, ''], [100, 0, ''], [200, 1, ''], [300, 1, ''], [400, 1, ''], [500, 0, '']])
    c.viewable_activities.map(&:id).should == [300,400]
    # Note viewable activites are ones where inclusion nesting values are not equal to 0 and the activity is published.
  end
end
