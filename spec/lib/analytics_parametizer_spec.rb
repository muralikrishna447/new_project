require 'spec_helper'

describe AnalyticsParametizer do
  let(:utm_with_term){ {'utm_source' => 'test1', "utm_campaign" => 'campaign1', "utm_term" => 'deleteme' } }
  let(:utm_with_medium){ {"utm_source" => 'test2', "utm_campaign" => 'campaign2', "utm_medium" => 'storeme' } }
  let(:utm_with_referer){ {"utm_source" => 'test2', "utm_campaign" => 'campaign2', "referer" => 'http://google.com' } }
  let(:utm_json){ {'utm' => {'utm_source'=>'test2', 'utm_campaign'=>'campaign2', 'utm_medium'=>'storeme' }.to_json} }

  describe 'get_params' do
    it 'should clear previous params if new params set' do
      results = AnalyticsParametizer.get_params(utm_with_medium, utm_with_term)
      results.should_not include(:utm_term)
      results.should include(:utm_medium)
      results[:utm_source].should == 'test2'
    end

    it 'should set params' do
      results = AnalyticsParametizer.get_params(utm_with_medium, {})
      results.should include(:utm_medium)
      results[:utm_source].should == 'test2'
    end

    it "should return cookie value if params aren't set" do
      results = AnalyticsParametizer.get_params({}, utm_json)
      results.should include("utm_medium")
      results["utm_source"].should == 'test2'
    end
  end

  describe "set_params" do
    it "should merge in the referer" do
      results = AnalyticsParametizer.set_params(utm_with_term, "http://google.com")
      JSON.parse(results)['referrer'].should == 'http://google.com'
    end

    it "shouldn't merge in referer if chefsteps" do
      results = AnalyticsParametizer.set_params(utm_with_referer, "http://chefsteps.com")
      JSON.parse(results).should_not include('referrer')
    end
  end
end
