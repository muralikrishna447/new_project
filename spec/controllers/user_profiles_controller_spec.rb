require 'spec_helper'

describe UserProfilesController do
  context 'Marketing email subscription management ' do
    it 'user trying to subscribe the newsletter' do
      @user = Fabricate :user, name: 'Bob Smith', email: 'test@test.com'
      sign_in @user
      BaseApplicationController.any_instance.should_receive(:email_list_signup)
      expect(@user.marketing_mail_status).to eq("unsubscribed")
      put :marketing_subscription, params: {id: @user.id, user: { marketing_mail_status: 'unsubscribed'}}
      expect(response).to redirect_to(user_profile_path(@user))
    end

    it 'user trying to unsubscribe the newsletter' do
      @user = Fabricate :user, name: 'Bob Smith', email: 'test@test.com', marketing_mail_status: 'subscribed'
      sign_in @user
      BaseApplicationController.any_instance.should_receive(:unsubscribe_from_mailchimp)
      expect(@user.marketing_mail_status).to eq("subscribed")
      put :marketing_subscription, params: {id: @user.id, user: { marketing_mail_status: 'subscribed'}}
      expect(response).to redirect_to(user_profile_path(@user))
    end

    it 'if user is pending status and trying to resend the newsletter consent mail for subscription' do
      @user = Fabricate :user, name: 'Bob Smith', email: 'test@test.com', marketing_mail_status: 'pending'
      sign_in @user
      BaseApplicationController.any_instance.should_receive(:email_list_signup)
      expect(@user.marketing_mail_status).to eq("pending")
      put :marketing_subscription, params: {id: @user.id, user: { marketing_mail_status: 'pending'}}
      expect(response).to redirect_to(user_profile_path(@user))
    end

    it 'invalid subscription status from old session value' do
      @user = Fabricate :user, name: 'Bob Smith', email: 'test@test.com' , marketing_mail_status: 'subscribed'
      sign_in @user
      BaseApplicationController.any_instance.should_not_receive(:email_list_signup)
      BaseApplicationController.any_instance.should_not_receive(:unsubscribe_from_mailchimp)
      put :marketing_subscription, params: {id: @user.id, user: { marketing_mail_status: 'unsubscribed'}}
      expect(response).to redirect_to(user_profile_path(@user))
    end
  end
end
