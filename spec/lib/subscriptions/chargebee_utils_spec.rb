require 'spec_helper'

describe Subscriptions::ChargebeeUtils do
  describe 'create_subscription' do
    let(:user_id) { '1234' }
    let(:email) { 'a@b.com'}
    let(:plan_id) { 'my_plan_id' }
    let(:coupon_id) { 'my_coupon_id' }

    before :each do
      WebMock.stub_request(:get, "https://.chargebee.com/api/v2/subscriptions?customer_id%5Bis%5D=#{user_id}&limit=1&plan_id%5Bis%5D=#{plan_id}&status%5Bin%5D=%5B%22active%22,%22in_trial%22,%22non_renewing%22,%22cancelled%22%5D").
        to_return(:status => 200, :body => list_body, :headers => {})
    end

    context 'user has existing subscription' do
      let(:subscription) {
        {
            status: status,
            id: 1
        }
      }
      let(:list_body) { { list: [{ customer: customer, subscription: subscription }] }.to_json }

      before(:each) {
        ChargeBee::Subscription.should_receive(:create).exactly(0).times
        ChargeBee::Subscription.should_receive(:create_for_customer).exactly(0).times
      }

      context 'active' do
        let(:status) { 'active'}
        let(:customer) { {} }

        it 'does not create subscription' do
          Subscriptions::ChargebeeUtils.create_subscription(user_id, email, plan_id, coupon_id)
        end
      end

      context 'cancelled' do
        let(:status) { 'cancelled'}
        let(:customer) { { promotional_credits: 10} }
        let(:new_term_end) { Time.now.to_i }

        it 'reactivates the subscription' do
          ChargeBee::Subscription.should_receive(:reactivate).with(subscription[:id], { invoice_immediately: true, billing_cycles: 1}).once
          Subscriptions::ChargebeeUtils.create_subscription(user_id, email, plan_id, coupon_id)
        end
      end

      context 'non_renewing' do
        let(:status) { 'non_renewing'}
        let(:customer) { { promotional_credits: 10} }
        let(:new_term_end) { Time.now.to_i }

        it 'extends term' do
          ChargeBee::Subscription.should_receive(:change_term_end).with(subscription[:id], { term_ends_at: new_term_end }).once
          Subscriptions::ChargebeeUtils.should_receive(:calculate_new_term_end).and_return(new_term_end)
          Subscriptions::ChargebeeUtils.create_subscription(user_id, email, plan_id, coupon_id)
        end
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

  describe 'calculate_new_term_end' do
    let(:plan_amount) {
      10
    }
    let(:current_term_end) {
      (Time.now + 1.month).to_i
    }
    let(:subscription) {
      double('subscription', :plan_amount => plan_amount, :current_term_end => current_term_end, :billing_period_unit => billing_period_unit)
    }

    context 'billing_period_unit = year' do
      let(:billing_period_unit) { "year"  }

      it 'adds 1 year' do
        new_term_end = Subscriptions::ChargebeeUtils.calculate_new_term_end(subscription, plan_amount)
        expect(new_term_end).should eq((Time.at(current_term_end) + 1.year).to_i)
      end
      it 'adds 2 years' do
        new_term_end = Subscriptions::ChargebeeUtils.calculate_new_term_end(subscription, plan_amount * 2)
        expect(new_term_end).should eq((Time.at(current_term_end) + 2.years).to_i)
      end
      it 'adds 0 years' do
        new_term_end = Subscriptions::ChargebeeUtils.calculate_new_term_end(subscription, 0)
        expect(new_term_end).should eq(Time.at(current_term_end).to_i)
      end
      it 'handles promotional credits not being multiple of plan_amount' do
        new_term_end = Subscriptions::ChargebeeUtils.calculate_new_term_end(subscription, plan_amount * 1.5)
        expect(new_term_end).should eq((Time.at(current_term_end) + 1.year).to_i)
      end
    end

    context 'billing_period_unit = month' do
      let(:billing_period_unit) { "month" }
      it 'adds 1 month' do
        new_term_end = Subscriptions::ChargebeeUtils.calculate_new_term_end(subscription, plan_amount)
        expect(new_term_end).should eq((Time.at(current_term_end) + 1.month).to_i)
      end
    end
  end

end
