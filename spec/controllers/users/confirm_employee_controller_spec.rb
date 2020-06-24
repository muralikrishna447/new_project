require 'spec_helper'

describe Users::ConfirmEmployeeController do
  describe 'confirm' do
    context 'auth token has invalid format' do
      let(:token) { 'ABC123'}

      it 'renders invalid' do
        get :confirm, params: { token: token }
        expect(response).to render_template(:invalid)
      end
    end

    context 'auth token is invalid' do
      let(:user) { Fabricate(:user) }
      let(:token) { user.create_restricted_token('bad_restriction', 1.day).to_jwt }

      it 'renders invalid' do
        get :confirm, params: { token: token }
        expect(response).to render_template(:invalid)
      end
    end

    context 'auth token is valid' do
      let(:user) { Fabricate(:user) }
      let(:token) { user.create_restricted_token(EmployeeAccountProcessor::TOKEN_RESTRICTION, 1.day).to_jwt }

      before do
        Subscriptions::ChargebeeUtils.should_receive(:grant_employee_subscriptions).with(user.id, user.email)
      end

      it 'grants employee subscriptions' do
        get :confirm, params: { token: token }
        expect(response).to redirect_to("https://www.#{Rails.application.config.shared_config[:chefsteps_endpoint]}/studiopass")
      end
    end
  end
end
