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

  context 'APIs' do
    context 'authenticated' do
      let(:subscription) {
        double('subscription', :id => 'subscription1', :plan_id => 'test', :plan_quantity => 1, :plan_unit_price => 6900, :plan_amount => 6900, :currency_code => 'USD')
      }
      let(:gifter) {
        double('gifter', :signature => 'something', :note => 'note')
      }
      let(:gift_receiver) {
        double('gift_receiver', :email => @user.email)
      }
      let(:gift) {
        double('gift', :id => 'gift1', :gifter => gifter, :status => 'unclaimed', :gift_receiver => gift_receiver)
      }
      let(:entry) {
        double('entry', :subscription => subscription, :gift => gift)
      }

      before do
        @user = Fabricate :user, email: 'johndoe@chefsteps.com', password: '123456', name: 'John Doe'
        controller.request.env['HTTP_AUTHORIZATION'] = @user.valid_website_auth_token.to_jwt
      end

      describe 'generate_checkout_url' do
        let(:result) {
          double('result', :hosted_page => {})
        }

        it 'calls checkout_gift if params[:is_gift]' do
          ChargeBee::HostedPage.should_receive(:checkout_gift).and_return(result)
          ChargeBee::HostedPage.should_not_receive(:checkout_new)

          params = { :is_gift => true, :plan_id => 'test' }
          post :generate_checkout_url, params

          response.code.should eq("200")
        end

        it 'calls checkout_new if params[:is_gift] is false' do
          ChargeBee::HostedPage.should_not_receive(:checkout_gift)
          ChargeBee::HostedPage.should_receive(:checkout_new).and_return(result)

          params = { :is_gift => false, :plan_id => 'test' }
          post :generate_checkout_url, params

          response.code.should eq("200")
        end
      end

      describe 'unclaimed gifts' do
        it 'returns empty result when no gifts' do
          ChargeBee::Gift.should_receive(:list).and_return([])

          get :unclaimed_gifts

          response.code.should eq("200")
          response_data = JSON.parse(response.body)
          response_data["results"].should eq([])
        end

        it 'returns a list of gifts' do
          ChargeBee::Gift.should_receive(:list).and_return([entry])

          get :unclaimed_gifts

          response.code.should eq("200")
          response_data = JSON.parse(response.body)
          response_data["results"].length.should eq(1)
          response_data["results"][0]["subscription"]["id"].should eq(subscription.id)
          response_data["results"][0]["gift"]["id"].should eq(gift.id)
          response_data["results"][0]["gift"]["gifter"]["signature"].should eq(gifter.signature)
        end
      end

      describe 'claim_gifts' do
        it 'rejects requests without gift_ids' do
          post :claim_gifts, {}
          response.code.should eq("400")
        end

        context 'with already claimed gift' do
          let(:gift) {
            double('gift', :id => 'gift1', :gifter => gifter, :status => 'claimed', :gift_receiver => gift_receiver)
          }
          it 'rejects the request' do
            ChargeBee::Gift.should_receive(:retrieve).and_return(entry)
            params = {
                :gift_ids => [gift.id]
            }
            post :claim_gifts, params
            response.code.should eq("401")
          end
        end

        context 'with mismatched email' do
          let(:gift_receiver) {
            double('gift_receiver', :email => 'doesnotmatch')
          }
          it 'rejects the request' do
            ChargeBee::Gift.should_receive(:retrieve).and_return(entry)
            params = {
                :gift_ids => [gift.id]
            }
            post :claim_gifts, params
            response.code.should eq("401")
          end
        end
      end
    end

    context 'not authenticated' do
      describe 'generate_checkout_url' do
        it 'returns unauthorized' do
          params = { :is_gift => false, :plan_id => 'test' }
          post :generate_checkout_url, params
          response.code.should eq("401")
        end
      end
    end
  end
end
