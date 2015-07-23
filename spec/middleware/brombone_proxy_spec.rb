require 'spec_helper'

describe 'brombone_proxy' do |variable|
  let(:app) do
    # directly return the env so it can be inspected - surely there is a better way!
    lambda { |env| [200, env] }
  end

  let :middleware do
    BromboneProxy.new(app)
  end

  before :each do
  end

  it 'Is alive' do
    re = request_env
    code, env = middleware.call request_env
    code.should be(200)
    env.should be(8)
  end

  def request_env opts = {}
    x = Rack::MockRequest.env_for('http://chefsteps.com/activities/booze?_escaped_fragment_=x', opts)
    puts x.inspect
    x
  end
end