require 'spec_helper'

describe AnalyticsParametizer do
  let(:utm_with_term){ {'utm_source' => 'test1', "utm_campaign" => 'campaign1', "utm_term" => 'storeme' } }
  let(:utm_with_medium){ {"utm_source" => 'test2', "utm_campaign" => 'campaign2', "utm_medium" => 'deleteme' } }
  let(:utm_with_referrer){ {"utm_source" => 'test3', "utm_campaign" => 'campaign3', "referer" => 'http://google.com' } }
  let(:utm_json){ {'utm' => {'utm_source'=>'test4', 'utm_campaign'=>'campaign4', 'utm_medium'=>'deleteme' }.to_json} }
  let(:utm_json_referrer){ {'utm' => {'utm_source'=>'test5', 'utm_campaign'=>'campaign5', 'utm_medium'=>'deleteme', 'referrer'=>"http://google.com" }.to_json} }

  describe 'cookie_value' do
    it 'should clear previous params if new params set' do
      json_results = AnalyticsParametizer.cookie_value(utm_with_term, utm_json, "http://google.com")
      results = JSON.parse(json_results)
      results.should include('utm_term', 'utm_source', 'utm_campaign')
      results.should_not include('utm_medium')
      results['utm_source'].should == 'test1'
      results['referrer'].should == 'http://google.com'
    end

    it 'should set params' do
      json_results = AnalyticsParametizer.cookie_value(utm_with_medium, {}, "http://google.com")
      results = JSON.parse(json_results)
      results.should include('utm_medium', 'utm_source', 'utm_campaign')
      results['utm_source'].should == 'test2'
      results['utm_campaign'].should == 'campaign2'
      results['utm_medium'].should == 'deleteme'
      results['referrer'].should == 'http://google.com'
    end

    it "should clear cookie values if referrer isn't chefsteps" do
      json_results = AnalyticsParametizer.cookie_value({}, utm_json, "http://google.com")
      results = JSON.parse(json_results)
      results.should_not include("utm_medium", 'utm_source', 'utm_campaign')
      results.should include("referrer")
      results["referrer"].should == 'http://google.com'
    end

    it "should merge in the referrer" do
      json_results = AnalyticsParametizer.cookie_value(utm_with_medium, {}, "http://google.com")
      results = JSON.parse(json_results)
      results["referrer"].should == 'http://google.com'
      results['utm_medium'].should == 'deleteme'
      results['utm_source'].should == 'test2'
      results['utm_campaign'].should == 'campaign2'
    end

    it "should not merge in the referrer when it is chefsteps" do
      json_results = AnalyticsParametizer.cookie_value(utm_with_medium, {}, "http://chefsteps.com")
      results = JSON.parse(json_results)
      results.should include('utm_medium', 'utm_source', 'utm_campaign')
      results.should_not include("referrer")
      results['utm_medium'].should == 'deleteme'
      results['utm_source'].should == 'test2'
      results['utm_campaign'].should == 'campaign2'
    end

    it "should keep the previous cookie values if referrer is chefsteps.com" do
      json_results = AnalyticsParametizer.cookie_value({}, utm_json_referrer, "http://chefsteps.com")
      results = JSON.parse(json_results)
      results.should include("referrer", 'utm_source', 'utm_campaign', 'utm_medium')
      results["referrer"].should == "http://google.com"
      results['utm_source'].should == 'test5'
      results['utm_campaign'].should == 'campaign5'
      results['utm_medium'].should == 'deleteme'
    end
  end
end
