require 'spec_helper'

describe ForumSsoController, type: :controller do

  it 'redirects to sign up if register param set' do
    get :authenticate, register: 1
    response.should redirect_to new_user_registration_path
  end

  it 'redirects to log in if there is no authenticated user' do
    get :authenticate
    response.should redirect_to new_user_session_path
  end

  context 'user is authenticated' do
    let(:user) { Fabricate(:user) }
    before do
      controller.stub(:calculate_hash) { 'test_hash' }
      sign_in user
      get :authenticate
    end

    subject { Rack::Utils.parse_query(URI.parse(response.location).query) }

    it 'returns query string with user id' do
      subject['userid'].should == user.id.to_s
    end

    it 'returns query string with user email' do
      subject['email'].should == user.email.to_s
    end

    it 'returns query string with user name' do
      subject['name'].should == user.name.to_s
    end

    it 'returns query string with unix timestamp' do
      subject['t'].should be
    end

    it 'returns query string with hash' do
      subject['hash'].should == 'test_hash'
    end

    it 'redirects the user to forum login' do
      response.location.should start_with ForumSsoController::FORUM_LOGIN_URL
    end
  end

  describe '#calculate_hash' do
    let(:secret) { 'ABCD' }
    let(:query) { 'foo=bar' }
    before do
      stub_const('ForumSsoController::DOZUKI_SECRET', secret)
    end

    it 'hashes query plus secret' do
      controller.send(:calculate_hash, query).should == Digest::SHA1.hexdigest("#{query}#{secret}")
    end
  end

end
