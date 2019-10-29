require 'spec_helper'

describe Subscriptions::ChargebeeUtils do
  describe 'grant_employee_subscription' do
    let(:user_id) { '1234' }
    let(:email) { 'a@b.com'}
    let(:plan_id) { 'my_plan_id' }
    let(:coupon_id) { 'my_coupon_id' }

    before :each do
      WebMock.stub_request(:get, "https://.chargebee.com/api/v2/subscriptions?customer_id%5Bis%5D=#{user_id}&limit=1&plan_id%5Bis%5D=#{plan_id}").
        to_return(:status => 200, :body => list_body, :headers => {})
    end

    context 'employee is already subscribed' do
      let(:list_body) { { list: [{ customer: {} }] }.to_json }

      it 'does not create subscription' do
        ChargeBee::Subscription.should_receive(:create).exactly(0).times
        ChargeBee::Subscription.should_receive(:create_for_customer).exactly(0).times

        Subscriptions::ChargebeeUtils.grant_employee_subscription(user_id, email, plan_id, coupon_id)
      end
    end

    context 'employee is not already subscribed' do
      before :each do
        WebMock.stub_request(:get, "https://.chargebee.com/api/v2/customers/#{user_id}").
            to_return(:status => status, :body => body, :headers => {})
      end

      let(:list_body) { { list: [] }.to_json }

      context 'customer exists' do
        let(:body) { {}.to_json }
        let(:status) { 200 }

        it 'creates subscription for customer' do
          ChargeBee::Subscription.should_receive(:create_for_customer).with(user_id, { plan_id: plan_id, coupon_ids: [coupon_id] })
          Subscriptions::ChargebeeUtils.grant_employee_subscription(user_id, email, plan_id, coupon_id)
        end
      end

      context 'customer does not exist' do
        let(:body) { '{"message":"Sorry, we couldn\'t find that resource","type":"invalid_request","api_error_code":"resource_not_found","error_code":"resource_not_found","error_msg":"Sorry, we couldn\'t find that resource","http_status_code":404}' }
        let(:status) { 404 }

        it 'creates subscription and customer' do
          ChargeBee::Subscription.should_receive(:create).with({ plan_id: plan_id, coupon_ids: [coupon_id], customer: { id: user_id, email: email } })
          Subscriptions::ChargebeeUtils.grant_employee_subscription(user_id, email, plan_id, coupon_id)
        end
      end
    end
  end
end
