require 'spec_helper'

describe 'auth_token_injector' do |variable|
  let(:app) do
    # directly return the env so it can be inspect - surely there is a better way!
    lambda { |env| [200, env] }
  end

  let :middleware do
    TokenAuthInjector.new(app)
  end

  it 'Does not set auth token cookie when user is not logged in' do
    code, env = middleware.call request_env
    env["action_dispatch.cookies"].instance_variable_get("@set_cookies").should be_nil
  end

  it 'Does not set auth token when cookie already exists' do
    code, env = middleware.call request_env auth_token: 'magic-token', user_id: 345
    env["action_dispatch.cookies"].instance_variable_get("@set_cookies").should be_empty
  end

  it 'Sets auth token cookie when none provided' do
    code, env = middleware.call request_env user_id: 345
    # Ready private from cookie jar is certainly not ideal
    cookie = env["action_dispatch.cookies"].instance_variable_get("@set_cookies")['_chefsteps_token']
    cookie.should_not be_nil
    cookie[:expires].should_not be_nil
  end

  def request_env opts = {}
    puts "OOPTS #{opts.inspect}"
    #session = Rack::MockSession.new app
    #session.set_cookie "_chefsteps_session=BAh7CUkiEF9jc3JmX3Rva2VuBjoGRUZJIjFmTTl3bFRURy9RR2hJYjZ3YkNQdXpYcDlwNjhnYXB3QWJBdGt6YnNLQW5JPQY7AEZJIg9zZXNzaW9uX2lkBjsARkkiJWEwNjRiMmU0NjZkYmRmOTczYjEwZDIzNzlmZTVlOTc1BjsAVEkiGXdhcmRlbi51c2VyLnVzZXIua2V5BjsAVFsISSIJVXNlcgY7AEZbBmkC%2FytJIiIkMmEkMTAkLm5nczlJVnpFcEFPOHNjaXZvTVRHdQY7AFRJIhN1c2VyX3JldHVybl90bwY7AEYiEy91c2Vycy9zaWduX2lu--8d3972e9b15782bae08c312a85913d3909dd4f7e;"
    session = {}
    if opts.has_key? :user_id
      session['warden.user.user.key'] = ["User", [opts['user_id']], 'nonsense']
    end
    opts['rack.session'] = session
    opts['HTTP_COOKIE'] = ""
    if opts.has_key? :auth_token
      opts["HTTP_COOKIE"] += "_chefsteps_token=#{opts[:auth_token]}"
    end
    Rack::MockRequest.env_for('chefsteps.com', opts)
  end
end
