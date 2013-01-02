require 'spec_helper'

describe Course do
  let(:course1) { Fabricate(:course, title: 'Course 1') }
  let(:course2) { Fabricate(:course, title: 'Course 2') }

  describe "set order" do
    it "creates unique equipment for each non-empty attribute set" do
      course1.course_order = 2
      course2.course_order = 1
      Course.collect.should have(2).course
    end

  end

end
