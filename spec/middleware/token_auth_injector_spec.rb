require 'spec_helper'

describe 'auth_token_injector' do |variable|
  let(:app) do
    # directly return the env so it can be inspected - surely there is a better way!
    lambda { |env| [200, env] }
  end

  let :middleware do
    TokenAuthInjector.new(app)
  end

  before :each do
    user = Fabricate :user, id: 345
    @aa = ActorAddress.create_for_user(user, unique_key: 'website')
    user = Fabricate :user, id: 789
  end

  it 'Does not set auth token cookie when user is not logged in' do
    code, env = middleware.call request_env
    env["action_dispatch.cookies"].instance_variable_get("@set_cookies").should be_nil
  end

  it 'Does not set auth token when valid token already exists' do
    code, env = middleware.call request_env auth_token: @aa.current_token.to_jwt, user_id: 345
    env["action_dispatch.cookies"].instance_variable_get("@set_cookies").should be_empty
  end

  it 'Handles invalid auth token' do
    code, env = middleware.call request_env auth_token: "not-an-auth-token", user_id: 345
    # should still set a proper auth token
    auth_token_from_env(env).should_not be_nil
  end

  it 'Sets auth token when none provided' do
    code, env = middleware.call request_env user_id: 789
    first_token = auth_token_from_env(env)

    aa = ActorAddress.where(actor_type: 'User', actor_id: 789, unique_key: 'website').first
    aa.should_not be_nil

    # Call second time to ensure that existing actor is re-used
    code, env = middleware.call request_env user_id: 789
    second_token = auth_token_from_env env
    first_token[:address_id].should == second_token[:address_id]
  end

  it 'Refreshes token older than 2 days' do
    token = @aa.current_token
    token.claim[:iat] = 3.days.ago.to_i
    code, env = middleware.call request_env auth_token: token.to_jwt, user_id: 345

    received_token = auth_token_from_env(env)
    received_token.age.should < 10.seconds
  end


  def request_env opts = {}
    session = {}

    # Emulate the behaviour of the warden manager
    if opts.has_key? :user_id
      session['warden.user.user.key'] = ["User", [opts[:user_id]], 'nonsense']
    end

    opts['rack.session'] = session
    opts['HTTP_COOKIE'] = ""
    if opts.has_key? :auth_token
      opts["HTTP_COOKIE"] += "_chefsteps_token=#{opts[:auth_token]}"
    end
    Rack::MockRequest.env_for('chefsteps.com', opts)
  end

  def auth_token_from_env (env)
    cookie = env["action_dispatch.cookies"].instance_variable_get("@set_cookies")['_chefsteps_token']
    cookie.should_not be_nil
    AuthToken.from_string(cookie[:value])
  end
end
