require 'spec_helper'

describe AnalyticsParametizer do

  let(:existing_cookie) do
    {
      utm: {
        utm_campaign: 'old_campaign',
        utm_source: 'old_source',
        utm_medium: 'old_medium',
        utm_term: 'old_term',
        referrer: 'http://old.co'
      }
    }.to_json
  end
  let(:utm_params){ { 'utm_source' => 'test_source', 'utm_medium' => 'test_medium'} }
  let(:referrer){ 'http://new.co' }

  describe 'cookie_value' do
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

    it "should clear or overwrite old cookies set by previous sessions when referrer is external" do
      new_cookie = AnalyticsParametizer.cookie_value({}, existing_cookie, 'other_co_property.com')
      new_values = JSON.parse(new_cookie)
      new_values.should_not include('utm_term')
      new_values.should_not include('utm_source')
      new_values.should_not include('utm_medium')
      new_values.should_not include('utm_campaign')
      new_values['referrer'].should == 'other_co_property.com'
    end

    it "should persist landing page cookie values across page views" do
      entry_cookie = AnalyticsParametizer.cookie_value(utm_params, {}, referrer)
      new_cookie = AnalyticsParametizer.cookie_value({}, { 'utm' => entry_cookie }, 'www.chefsteps-test-endpoint.com')
      new_values = JSON.parse(new_cookie)
      new_values['utm_source'].should == utm_params['utm_source']
      new_values['utm_medium'].should == utm_params['utm_medium']
      new_values['referrer'].should == referrer
    end

    it "should persist landing page cookie values when referrer is blank" do
      entry_cookie = AnalyticsParametizer.cookie_value(utm_params, {}, referrer)
      new_cookie = AnalyticsParametizer.cookie_value({}, { 'utm' => entry_cookie }, nil)
      new_values = JSON.parse(new_cookie)
      new_values['utm_source'].should == utm_params['utm_source']
      new_values['utm_medium'].should == utm_params['utm_medium']
      new_values['referrer'].should == referrer
    end


    it "should handle a corrupted cookie cookie values across page views" do
      new_cookie = AnalyticsParametizer.cookie_value({}, { 'utm' => 'asdasd' }, 'www.chefsteps-test-endpoint.com')
      new_values = JSON.parse(new_cookie)
      new_values['utm_source'].should be_nil
      new_values['utm_medium'].should be_nil
      new_values['referrer'].should be_nil
    end
  end
end
