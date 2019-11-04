require 'spec_helper'

describe Api::V0::ChargebeeController do
  context 'webhook' do

    before(:each) do
      @user = Fabricate :user, email: 'johndoe@chefsteps.com', password: '123456', name: 'John Doe'
      Api::V0::ChargebeeController.any_instance.stub(:chargebee_webhook_key).and_return('testKey')
    end

    context 'with authentication' do
      before(:each) do
        @request.env['HTTP_AUTHORIZATION'] = "Basic testKey"
      end

      it 'creates and updates a subscription' do
        plan_id = "testPlan"
        params = {
          api_version: "v2",
          content: {
              customer: {
                id: @user.id
              },
              subscription: {
                plan_id: plan_id,
                resource_version: 1517507544000,
                status: "active"
              }
          },
          event_type: "subscription_created",
          id: "ev___test__5SK0bLNFRFuFaqltU",
          object: "event"
        }
        expect(Subscription.user_has_subscription?(@user, plan_id)).to be_false

        post :webhook, params

        response.code.should eq("200")
        expect(Subscription.user_has_subscription?(@user, plan_id)).to be_true


        # Cancel the subscription
        params[:content][:subscription][:status] = "cancelled"
        params[:content][:subscription][:resource_version] += 1

        post :webhook, params

        response.code.should eq("200")
        expect(Subscription.user_has_subscription?(@user, plan_id)).to be_false

        # Ignores out of order requests
        params[:content][:subscription][:status] = "active"
        params[:content][:subscription][:resource_version] -= 1

        post :webhook, params

        response.code.should eq("200")
        expect(Subscription.user_has_subscription?(@user, plan_id)).to be_false
      end
      
    end

    context 'without authentication' do
      it 'rejects unauthenticated requests' do
        post :webhook, {}
        response.code.should eq("403")
      end
    end
  end
end
