require 'spec_helper'

Rails.logger = Logger.new(STDOUT)
describe 'freshsteps_proxy' do |variable|

  let(:app) do
    lambda { |env| [200, env] }
  end

  it 'Proxy /joule' do
    # Staging-like config, blog everything except API
    @freshsteps_proxy = FreshStepsProxy.new(app)

    assert_proxy '/joule', true
    assert_proxy '/joule/', true
    assert_proxy '/joule/hardware', true
    assert_proxy '/joule-overview', true
    assert_proxy '/joule/warranty', false
    assert_proxy '/joule/warranty/XY', false
  end

  it 'Proxy /gallery' do
    # Staging-like config, blog everything except API
    @freshsteps_proxy = FreshStepsProxy.new(app)

    assert_proxy '/gallery', true
  end

  it 'should not proxy /profiles' do
    # Staging-like config, blog everything except API
    @freshsteps_proxy = FreshStepsProxy.new(app)

    assert_proxy '/profiles/123', false
  end

  def assert_proxy path, expected
    @env = {'PATH_INFO' => path}
    @freshsteps_proxy.should_proxy?(@env).should == expected
  end
end
