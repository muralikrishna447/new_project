require 'spec_helper'

Rails.logger = Logger.new(STDOUT)
describe 'preauth_enforcer' do |variable|
  it 'Exceptions should be enforced' do
    # Staging-like config, blog everything except API
    @pe = PreauthEnforcer.new nil, [/^\/api/], []
    #assert_passthrough '/', true
    assert_passthrough '/api/bleh', true
    assert_passthrough '/', false
    assert_passthrough '/premium', false
  end

  it 'Restrictions should be enforced' do
    # prod-like config
    @pe = PreauthEnforcer.new nil, [/.*/], [/^\/tpq/]
    assert_passthrough '/', true
    assert_passthrough '/premium', true
    assert_passthrough '/tpq', false
  end

  def assert_passthrough path, expected
    @env = {'REQUEST_PATH' => path}
    puts @env.inspect
    @pe.passthrough?(@env).should == expected
  end
end
