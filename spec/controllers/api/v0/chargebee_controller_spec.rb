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
        double('gift', :id => 'gift1', :gifter => gifter, :status => 'unclaimed', :gift_receiver => gift_receiver, :gift_timelines => [unclaimed_event])
      }
      let(:entry) {
        double('entry', :subscription => subscription, :gift => gift)
      }
      let(:claimed_event) {
        double('claimed_event', :status => 'claimed', :occurred_at => 1572480084)
      }
      let(:unclaimed_event) {
        double('unclaimed_event', :status => 'unclaimed', :occurred_at => 1571862970)
      }
      let(:claimed_gift) {
        double('gift2', :id => 'gift2', :gifter => gifter, :status => 'claimed', :gift_receiver => gift_receiver, :gift_timelines => [unclaimed_event, claimed_event])
      }
      let(:claimed_entry) {
        double('entry2', :subscription => subscription, :gift => claimed_gift)
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
          ChargeBee::Customer.should_receive(:retrieve).and_return(@user.id)
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

      describe 'gifts' do
        it 'returns empty result when no gifts' do
          list_result = []
          list_result.define_singleton_method(:next_offset) do
            nil
          end

          ChargeBee::Gift.should_receive(:list).and_return(list_result)

          get :gifts

          response.code.should eq("200")
          response_data = JSON.parse(response.body)
          response_data["results"]["unclaimed"].should eq([])
          response_data["results"]["claimed"].should eq([])
        end

        it 'returns a list of gifts' do
          list_result = [entry, claimed_entry]
          list_result.define_singleton_method(:next_offset) do
            nil
          end

          ChargeBee::Gift.should_receive(:list).and_return(list_result)

          get :gifts

          response.code.should eq("200")
          response_data = JSON.parse(response.body)
          response_data["results"]["unclaimed"].length.should eq(1)
          response_data["results"]["unclaimed"][0]["subscription"]["id"].should eq(subscription.id)
          response_data["results"]["unclaimed"][0]["gift"]["id"].should eq(gift.id)
          response_data["results"]["unclaimed"][0]["gift"]["status"].should eq(gift.status)
          response_data["results"]["unclaimed"][0]["gift"]["gifter"]["signature"].should eq(gifter.signature)
          response_data["results"]["unclaimed"][0]["gift"]["claimed_time"].should be_nil

          response_data["results"]["claimed"].length.should eq(1)
          response_data["results"]["claimed"][0]["subscription"]["id"].should eq(subscription.id)
          response_data["results"]["claimed"][0]["gift"]["id"].should eq(claimed_gift.id)
          response_data["results"]["claimed"][0]["gift"]["status"].should eq(claimed_gift.status)
          response_data["results"]["claimed"][0]["gift"]["gifter"]["signature"].should eq(gifter.signature)
          response_data["results"]["claimed"][0]["gift"]["claimed_time"].should eq(claimed_gift.gift_timelines[1].occurred_at * 1000)
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

        context 'with case insensitive email' do
          let(:gift_receiver) {
            double('gift_receiver', :email => @user.email.upcase)
          }
          it 'allows the request' do
            ChargeBee::Gift.should_receive(:retrieve).and_return(entry)
            ChargeBee::Customer.should_receive(:retrieve).and_return(nil)
            Resque.should_receive(:enqueue).and_return(true)
            params = {
                :gift_ids => [gift.id]
            }
            post :claim_gifts, params
            response.code.should eq("200")
          end
        end
      end

      describe 'claim_complete' do
        before(:each) do
          ChargebeeGiftRedemptions.create!(:gift_id => '1', :user_id => 1, :plan_amount => 6900, :currency_code => 'USD')
          ChargebeeGiftRedemptions.create!(:gift_id => '2', :user_id => 1, :plan_amount => 6900, :currency_code => 'USD', :complete => true)
          ChargebeeGiftRedemptions.create!(:gift_id => '3', :user_id => 1, :plan_amount => 6900, :currency_code => 'USD', :complete => true)
        end

        it 'rejects requests without gift_ids' do
          get :claim_complete, {}
          response.code.should eq("400")
        end

        it 'rejects requests with two many gift ids' do
          gift_ids = []
          (0..31).each {|i| gift_ids.push(i.to_s)}

          get :claim_complete, {:gift_ids => gift_ids}
          response.code.should eq("400")
        end

        it 'returns false if at least one gift is not claimed' do
          get :claim_complete, {:gift_ids => ['1', '2', '3']}
          response.code.should eq("200")
          response_data = JSON.parse(response.body)
          response_data["complete"].should be_false
        end

        it 'returns true if all gifts are claimed' do
          get :claim_complete, {:gift_ids => ['2', '3']}
          response.code.should eq("200")
          response_data = JSON.parse(response.body)
          response_data["complete"].should be_true
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
