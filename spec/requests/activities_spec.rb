require 'spec_helper'

describe "Activities" do

  describe "Activity slugs" do
    before(:each) do
      @activity = Fabricate(:activity, title: 'Slug A Bug', published: true)
    end

    it "creates a basic slug", pending: true do
      visit activity_path(@activity)
      p1 = current_path
      p1.should eq "/activities/slug-a-bug"
    end

    it "remembers history of slugs, redirects old ones", pending: true do

      visit activity_path(@activity)
      p1 = current_path

      @activity.update_attributes(title: "Bug In A Rug")
      visit activity_path(@activity)
      p2 = current_path
      p2.should eq "/activities/bug-in-a-rug"

      # First redirect, while still private
      visit(p1)
      current_path.should eq p2

      @activity.update_attributes(title: "Wheedle On Needle", description: "Blarmey", published: true)
      visit activity_path(@activity)
      page.status_code.should == 200
      p3 = current_path
      p3.should eq "/activities/wheedle-on-needle"

      # First and second redirects, now to public
      visit(p1)
      current_path.should eq p3
      page.status_code.should == 200
      visit(p2)
      current_path.should eq p3
      page.status_code.should == 200
    end

    it "passes token, minimal, and version params through redirect", pending: true do
      visit activity_path(@activity)
      p1 = current_path_info
      @activity.update_attributes(title: "Bug In A Rug")
      visit activity_path(@activity, token: "foo", minimal: true, version: 3)
      current_path_info.should eq("/activities/bug-in-a-rug?minimal=true&token=foo&version=3")
    end

  end

end
