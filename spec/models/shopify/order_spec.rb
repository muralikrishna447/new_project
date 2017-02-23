require 'spec_helper'

describe Shopify::Order do
  JOULE_ORDER_ID = 4507800
  FREE_JOULE_ORDER_ID = 4507801
  PREMIUM_ORDER_ID = 450789469
  SIMPLE_ORDER_ALL_BUT_JOULE = 100001
  SIMPLE_ORDER_PARTIALLY_FULFILLED = 100002
  SIMPLE_ORDER_FULFILLED = 100003
  SIMPLE_ORDER_UNFULFILLED = 100004
  PREMIUM_GIFT_ORDER = 100005
  UNPAID_PREMIUM_ORDER_ID = 100006

  context 'order retrieval' do
    it 'retrieves an order' do
      Shopify::Order.find(PREMIUM_ORDER_ID).should_not be_nil
    end

    it 'raises for non-existent orders' do
      WebMock.stub_request(:get, /\.com\/admin\/orders\/9999\.json/).
        to_return(:status => 404, :body => "", :headers => {})
      expect {
        Shopify::Order.find(9999)
      }.to raise_error(ActiveResource::ResourceNotFound)
    end
  end

  context 'order fulfillment' do
    before(:each) do
      @user = Fabricate(:user, :id => 123)

      # Carelessly duplicated from customer spec
      customer_data = [JSON.parse(ShopifyAPI::Mock::Fixture.find('customers').data)['customers'][0]]
      WebMock.stub_request(:get, /\.com\/admin\/customers\/search.json\?query=email:%22.*%22/).
           to_return(:status => 200, :body => customer_data.to_json, :headers => {})

      Analytics.should_receive(:flush)
    end

    it 'fulfills a simple joule order' do

      # Not stubbing fulfillment call since this is not made for joule
      WebMock::stub_request(:put, /\.com\/admin\/orders\/4507800.json/).
        to_return(:status => 200, :body => "", :headers => {})
      stub_metafield_get
      Shopify::Customer.should_receive(:sync_user)
      stub_metafield_post('all-but-joule-fulfilled', 'true')
      @user.premium?.should == false
      @user.joule_purchase_count.should == 0
      order = Shopify::Order.find(JOULE_ORDER_ID)
      order.process!
      @user.reload
      @user.joule_purchase_count.should == 1
      # No premium with joule!
      @user.premium?.should == false

    end
    it 'fulfills a zero-dollar joule order' do
      # Not stubbing fulfillment call since this is not made for joule
      WebMock::stub_request(:put, /\.com\/admin\/orders\/4507800.json/).
        to_return(:status => 200, :body => "", :headers => {})
      JouleConfirmationMailer.should_not_receive(:prepare)
      stub_metafield_get
      Shopify::Customer.should_receive(:sync_user)
      stub_metafield_post('all-but-joule-fulfilled', 'true')
      @user.premium?.should == false
      @user.joule_purchase_count.should == 0
      order = Shopify::Order.find(FREE_JOULE_ORDER_ID)
      order.process!
      @user.reload
      @user.joule_purchase_count.should == 1
      # No premium with joule!
      @user.premium?.should == false

    end
    it 'fulfills premium gift order' do

      stub_fulfillment
      stub_metafield_get
      order = Shopify::Order.find(PREMIUM_GIFT_ORDER).process!
    end

    it 'joule order for premium customer doesnt send premium welcome email' do
      @user.make_premium_member(20)
      Shopify::Customer.should_receive(:sync_user)
      stub_metafield_post('all-but-joule-fulfilled', 'true')
      stub_metafield_get
      Shopify::Order.find(JOULE_ORDER_ID).process!
    end
  end

  context 'fulfillment checks' do
    it 'it knows if all but joule has been fulfilled' do
      stub_metafield_get([metafield_response('all-but-joule-fulfilled', 'true')])
      expect(Shopify::Order.find(SIMPLE_ORDER_ALL_BUT_JOULE).all_but_joule_fulfilled?).to be_true
    end

    it 'knows if order is fulfilled' do
      expect(Shopify::Order.find(SIMPLE_ORDER_FULFILLED).all_but_joule_fulfilled?).to be_true
    end

    it 'knows a partially fulfilled order is not fulfilled' do
      stub_metafield_get
      expect(Shopify::Order.find(SIMPLE_ORDER_PARTIALLY_FULFILLED).all_but_joule_fulfilled?).to be_false
    end

    it 'knows if order is unfulfilled' do
      stub_metafield_get
      expect(Shopify::Order.find(SIMPLE_ORDER_UNFULFILLED).all_but_joule_fulfilled?).to be_false
    end
  end

  context 'unpaid order' do
    it 'returns immediately if an order is unpaid' do
      order = Shopify::Order.find(UNPAID_PREMIUM_ORDER_ID)
      order.should_not_receive(:sync_user)
      order.should_not_receive(:send_analytics)
      order.process!
    end
  end

  describe 'fulfill_premium' do
    before(:each) do
      @user = Fabricate(:user, :id => 123)
    end

    it 'fulfills a simple premium order' do
      # TODO - assert actual email contents

      stub_fulfillment
      stub_metafield_get

      @user.premium?.should == false
      api_order = ShopifyAPI::Order.find(PREMIUM_ORDER_ID)
      order = Shopify::Order.new(api_order)
      order.fulfill_premium(api_order.line_items.first, true)
      @user.reload.premium?.should == true
    end
  end

  def stub_metafield_post(key, value)
    WebMock.stub_request(:post, /\.com\/admin\/orders\/.*\/metafields.json/).
      with(:body => {:metafield => {:namespace => 'chefsteps', :key => key, :value_type => 'string', :value=>value}}.to_json).
      to_return(:status => 200, :body => "", :headers => {})
  end

  def metafield_response(key, value)
    {'namespace' => 'chefsteps',
      'key' => key,
      'value' => value,
      'value_type' => 'string'
    }
  end

  def stub_metafield_get(metafields = [])
    WebMock.stub_request(:get, /\.com\/admin\/orders\/.*\/metafields.json/).
      to_return(:status => 200, :body => { "metafields" => metafields}.to_json, :headers => {})
  end

  def stub_fulfillment
    WebMock::stub_request(:post, /\.com\/admin\/orders\/.*\/fulfillments.json/).
      to_return(:status => 200, :body => "", :headers => {})
  end
end
