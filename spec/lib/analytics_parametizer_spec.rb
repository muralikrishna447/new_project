require 'spec_helper'

describe AnalyticsParametizer do

  let(:existing_cookie){ 
    { 
      utm: { 
        utm_source: 'old_source', 
        utm_medium: 'old_medium', 
        utm_term: 'old_term', 
        referrer: 'http://old.co' 
      }
    }.to_json 
  }
  let(:utm_params){ { 'utm_source' => 'test_source', 'utm_medium' => 'test_medium'} }
  let(:referrer){ 'http://new.co' }

  describe 'cookie_value', focus: true do
    it "should set utm params and referrer for new sessions" do
      new_cookie = AnalyticsParametizer.cookie_value(utm_params, {}, referrer)
      new_values = JSON.parse(new_cookie)
      new_values['utm_source'].should == utm_params['utm_source']
      new_values['utm_medium'].should == utm_params['utm_medium']
      new_values['referrer'].should == 'http://new.co'
    end

    it "should clear or overwrite old cookies set by previous sessions" do
      new_cookie = AnalyticsParametizer.cookie_value(utm_params, existing_cookie, nil)
      new_values = JSON.parse(new_cookie)
      new_values.should_not include('utm_term')
      new_values.should_not include('referrer')
      new_values['utm_source'].should_not == JSON.parse(existing_cookie)['utm']['utm_source']
      new_values['utm_source'].should == utm_params['utm_source']
    end

    it "should persist landing page cookie values across page views" do
      entry_cookie = AnalyticsParametizer.cookie_value(utm_params, {}, referrer)
      new_cookie = AnalyticsParametizer.cookie_value({}, { 'utm' => entry_cookie }, 'https://www.chefsteps.com')
      new_values = JSON.parse(new_cookie)
      new_values['utm_source'].should == utm_params['utm_source']
      new_values['utm_medium'].should == utm_params['utm_medium']
      new_values['referrer'].should == referrer
    end    
  end
end
