require 'spec_helper'

describe PublishingSchedule do
  funday = DateTime.parse "2066-12-07T12:00+00:00"
  funday_browser = "2066-12-07T04:00"
  summer_browser = "2066-08-01T00:00"
  winter_browser = "2066-01-12T00:00"
  past_browser = "1066-08-08T00:00"

  describe 'publish_at_pacific' do
    it "produces browser friendly Pacific time" do
      ps = Fabricate(:publishing_schedule, publish_at: funday)
      ps.publish_at_pacific.should == funday_browser
    end
  end

  describe 'publish_at_pacific=' do
    it "parses browser friendly Pacific time" do
      ps = Fabricate(:publishing_schedule, publish_at_pacific: funday_browser)
      ps.publish_at.should == funday
    end
  end

  describe 'times roundtrip' do
    it "works during PST" do
      ps = Fabricate(:publishing_schedule, publish_at_pacific: winter_browser)
      ps.publish_at_pacific.should == winter_browser
    end

    it "works during PDT" do
      ps = Fabricate(:publishing_schedule, publish_at_pacific: summer_browser)
      ps.publish_at_pacific.should == summer_browser
    end
  end
end