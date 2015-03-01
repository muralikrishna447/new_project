require 'spec_helper'

class Dummy
  include ActsAsSanitized
  attr_accessor :test_field_1, :test_field_2
end

describe ActsAsSanitized do
  describe ".sanitize_input" do
    it "should have a sanitize_input method" do
      (Dummy.new.methods-Object.new.methods).should include(:sanitize_input)
    end

    it "should sanitize out a javascript attribute" do
      dummy = Activity.new
      dummy.title = "<a href='javascript:alert(\'Bad Things\')'>Click me, I'm safe</a>"
      dummy.sanitize_input :title
      dummy.title.should eq "<a>Click me, I'm safe</a>"
    end

    it "should sanitize out a javascript script tag" do
      dummy = Activity.new
      dummy.title = "<script>alert('Bad Things')</script>"
      dummy.sanitize_input :title
      dummy.title.should eq "alert('Bad Things')"
    end

    it "should NOT sanitize out a link" do
      dummy = Activity.new
      dummy.title = "<a href='http://www.chefsteps.com/'>Come Visit Chefsteps</a>"
      dummy.sanitize_input :title
      dummy.title.should eq "<a href=\"http://www.chefsteps.com/\">Come Visit Chefsteps</a>"
    end

    it "should NOT sanitize out an image" do
      dummy = Activity.new
      dummy.title = "<img src='http://chefsteps.com/images/logo.gif'/>"
      dummy.sanitize_input :title
      dummy.title.should eq "<img src=\"http://chefsteps.com/images/logo.gif\">"
    end

    it "should NOT screw up json" do
      dummy = Activity.new
      dummy.title = "{'step': ['one', 'two', 'three'], 'testing': {'one': 'two', 'three': [4,5,6]}}"
      dummy.sanitize_input :title
      dummy.title.should eq "{'step': ['one', 'two', 'three'], 'testing': {'one': 'two', 'three': [4,5,6]}}"
    end
  end


end
