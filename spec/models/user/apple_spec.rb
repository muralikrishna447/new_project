require 'spec_helper'

describe User::Apple do
  describe 'apple_connnect' do
    let(:email) { 'a@b.com' }
    let(:apple_user_id) { 'apple_user_id' }
    let(:params) { { email: email, apple_user_id: apple_user_id, name: name } }
    let(:provider) { 'apple' }

    context 'name is present in params' do
      let(:name) { 'CS Fan' }

      it 'initializes user with specified name' do
        user = User.apple_connect(params)
        expect(user.email).to eq(email)
        expect(user.apple_user_id).to eq(apple_user_id)
        expect(user.provider).to eq(provider)
        expect(user.name).to eq(name)
      end
    end

    context 'name is not present in params' do
      let(:name) { nil }

      it 'initializes user with default name' do
        user = User.apple_connect(params)
        expect(user.email).to eq(email)
        expect(user.apple_user_id).to eq(apple_user_id)
        expect(user.provider).to eq(provider)
        expect(user.name).to eq(User::Apple::APPLE_USER_DEFAULT_NAME)
      end
    end
  end
end
