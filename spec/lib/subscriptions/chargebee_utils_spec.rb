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

        Subscriptions::ChargebeeUtils.create_subscription(user_id, email, plan_id, coupon_id)
      end
    end

    context 'employee is not already subscribed' do
      before :each do
        WebMock.stub_request(:get, "https://.chargebee.com/api/v2/customers/#{user_id}").
            to_return(:status => status, :body => body, :headers => {})
        subscription.should_receive(:status).at_least(:once).and_return('active')
        subscription.should_receive(:resource_version).at_least(:once).and_return(1)
        subscription_response.should_receive(:subscription).at_least(:once).and_return(subscription)
      end

      let(:list_body) { { list: [] }.to_json }
      let(:subscription) { double('subscription') }
      let(:subscription_response) { double('subscription_response') }

      context 'customer exists' do
        let(:body) { {}.to_json }
        let(:status) { 200 }

        it 'creates subscription for customer' do
          ChargeBee::Subscription
            .should_receive(:create_for_customer)
            .with(user_id, { plan_id: plan_id, coupon_ids: [coupon_id] })
            .and_return(subscription_response)
          Subscriptions::ChargebeeUtils.create_subscription(user_id, email, plan_id, coupon_id)
          expect(Subscription.where(user_id: user_id, plan_id: plan_id).length).to eq(1)
        end
      end

      context 'customer does not exist' do
        let(:body) { '{"message":"Sorry, we couldn\'t find that resource","type":"invalid_request","api_error_code":"resource_not_found","error_code":"resource_not_found","error_msg":"Sorry, we couldn\'t find that resource","http_status_code":404}' }
        let(:status) { 404 }

        it 'creates subscription and customer' do
          ChargeBee::Subscription
            .should_receive(:create)
            .with({ plan_id: plan_id, coupon_ids: [coupon_id], customer: { id: user_id, email: email } })
            .and_return(subscription_response)
          Subscriptions::ChargebeeUtils.create_subscription(user_id, email, plan_id, coupon_id)
          expect(Subscription.where(user_id: user_id, plan_id: plan_id).length).to eq(1)
        end
      end
    end
  end
end
