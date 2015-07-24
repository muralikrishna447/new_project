require 'spec_helper'

SRC_PATH = "/activities/booze"
SRC_URL = "http://chefsteps.com" + SRC_PATH
DST_PATH = '/www.chefsteps.com/activities/booze'

describe 'brombone_proxy' do |variable|
  let(:app) do
    lambda { |env| [200, env] }
  end

  let :middleware do
    BromboneProxy.new(app)
  end

  it 'Does not proxy normal request' do
    expect_no_proxy
    middleware.call request_env(SRC_URL)
  end

  it 'Does not proxy assets even if request has _escaped_fragment_ query param' do
    expect_no_proxy
    middleware.call request_env("http://chefsteps.com/fonts/fargug.woff")
  end

  it 'Proxies when request has _escaped_fragment_ query param' do
    expect_proxy
    response = middleware.call request_env("#{SRC_URL}?_escaped_fragment_=")
  end

  it 'Proxies when user agent looks like Google' do
    expect_proxy
    response = middleware.call request_env(SRC_URL, {'HTTP_USER_AGENT' => 'Googlebot/2.1 (+http://www.googlebot.com/bot.html)'})
  end

  it 'Proxies when user agent looks like Facebook' do
    expect_proxy
    response = middleware.call request_env(SRC_URL, {'HTTP_USER_AGENT' => 'facebookexternalhit/1.1 (+http://www.facebook.com/externalhit_uatext.php)'})
  end

  def expect_proxy
    middleware.should_receive(:perform_request) do |env|
      env["HTTP_HOST"].should eq("chefsteps.brombonesnapshots.com")
      env["REQUEST_PATH"].should eq(DST_PATH)
      env["REQUEST_URI"].should eq(DST_PATH)
      env["PATH_INFO"].should eq(DST_PATH)
      [200, {}, ""]
    end
  end

  def expect_no_proxy
    middleware.should_not_receive(:perform_request)
  end

  def request_env(uri, opts ={})
    Rack::MockRequest.env_for(uri, opts)
  end
end