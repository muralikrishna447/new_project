require 'spec_helper'

describe AnalyticsParametizer do
  let(:utm_with_term){ {'utm_source' => 'test1', "utm_campaign" => 'campaign1', "utm_term" => 'storeme' } }
  let(:utm_with_medium){ {"utm_source" => 'test2', "utm_campaign" => 'campaign2', "utm_medium" => 'deleteme' } }
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

    it "should work if referrer is not set" do
      json_results = AnalyticsParametizer.cookie_value(utm_with_medium, {}, nil)
      results = JSON.parse(json_results)
      results.should include('utm_medium', 'utm_source', 'utm_campaign')
      results.should include('referrer')
      results['referrer'].should be_nil
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

    it "should not merge in the referrer when it is chefsteps and should clear everything" do
      json_results = AnalyticsParametizer.cookie_value(utm_with_medium, {}, "http://www.chefsteps.com")
      results = JSON.parse(json_results)
      results.should_not include('utm_medium', 'utm_source', 'utm_campaign', "referrer")
    end

    it "should not merge in the referrer when it is chefsteps and should revert to cookie" do
      json_results = AnalyticsParametizer.cookie_value(utm_with_medium, utm_json_referrer, "http://www.chefsteps.com")
      results = JSON.parse(json_results)
      results.should include('utm_medium', 'utm_source', 'utm_campaign', "referrer")
      results['referrer'].should == 'http://google.com'
      results['utm_source'].should == 'test5'
      results['utm_campaign'].should == 'campaign5'
      results['utm_medium'].should == 'deleteme'
    end

    it "should merge in the referrer when it is blog.chefsteps.com" do
      json_results = AnalyticsParametizer.cookie_value(utm_with_medium, {}, "http://blog.chefsteps.com")
      results = JSON.parse(json_results)
      results.should include('utm_medium', 'utm_source', 'utm_campaign')
      results.should include("referrer")
      results['referrer'].should == 'http://blog.chefsteps.com'
    end

    it "should keep the previous cookie values if referrer is chefsteps.com" do
      json_results = AnalyticsParametizer.cookie_value({}, utm_json_referrer, "http://www.chefsteps.com")
      results = JSON.parse(json_results)
      results.should include("referrer", 'utm_source', 'utm_campaign', 'utm_medium')
      results["referrer"].should == "http://google.com"
      results['utm_source'].should == 'test5'
      results['utm_campaign'].should == 'campaign5'
      results['utm_medium'].should == 'deleteme'
    end
  end

  describe 'scenarios' do
    context "first page in session" do
      it "should set referrer and utm parameters" do
        # Coming in for the first time from an external link
        json_results = AnalyticsParametizer.cookie_value(utm_with_medium, {}, "http://google.com")
        results = JSON.parse(json_results)
        results.should include('utm_medium', 'utm_source', 'utm_campaign')
        results['utm_source'].should == 'test2'
        results['utm_campaign'].should == 'campaign2'
        results['utm_medium'].should == 'deleteme'
      end
    end
    context "second page in session" do
      it "should not set the referrer if internal" do
        # Coming in for the first time from an external link
        first_json_results = AnalyticsParametizer.cookie_value(utm_with_medium, {}, "http://google.com")
        # Second page in the session should have the cookie result from the first and referrer is chefsteps
        json_results = AnalyticsParametizer.cookie_value({}, {'utm' => first_json_results}, "http://www.chefsteps.com/joule")
        results = JSON.parse(json_results)
        results["referrer"].should == "http://google.com"
        results["referrer"].should_not == "http://www.chefsteps.com/joule"
        results['utm_medium'].should == 'deleteme'
        results['utm_source'].should == 'test2'
        results['utm_campaign'].should == 'campaign2'
      end

      it "should set the referrer if external and clear the cookie values" do
        # Coming in for the first time from an external link
        first_json_results = AnalyticsParametizer.cookie_value(utm_with_medium, {}, "http://google.com")
        results = JSON.parse(first_json_results)
        results['utm_medium'].should_not be_blank
        results['utm_source'].should_not be_blank
        results['utm_campaign'].should_not be_blank
        # Second page in the session should have the cookie result from the first and referrer is external
        json_results = AnalyticsParametizer.cookie_value({}, {'utm' => first_json_results}, "http://www.yahoo.com")
        results = JSON.parse(json_results)
        results["referrer"].should == "http://www.yahoo.com"
        results["referrer"].should_not == "http://www.google.com"
        results['utm_medium'].should be_blank
        results['utm_source'].should be_blank
        results['utm_campaign'].should be_blank
      end

      it "should not overwrite cookie values if new utm values are set but referrer is chefsteps.com" do
        # Coming in for the first time from an external link
        first_json_results = AnalyticsParametizer.cookie_value(utm_with_medium, {}, "http://www.google.com")
        results = JSON.parse(first_json_results)
        results['utm_medium'].should_not be_blank
        results['utm_source'].should_not be_blank
        results['utm_campaign'].should_not be_blank
        json_results = AnalyticsParametizer.cookie_value(utm_with_term, {'utm' => first_json_results}, "http://www.chefsteps.com")
        results['referrer'].should == 'http://www.google.com'
        results['utm_source'].should == 'test2'
        results['utm_campaign'].should == 'campaign2'
        results['utm_term'].should be_blank
      end


    end
  end
end
