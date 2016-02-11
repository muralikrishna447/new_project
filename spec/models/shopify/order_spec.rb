require 'spec_helper'

describe Shopify::Order do  
  JOULE_ORDER_ID = 4507800  
  PREMIUM_ORDER_ID = 450789469
  
  SIMPLE_ORDER_ALL_BUT_JOULE = 100001
  SIMPLE_ORDER_PARTIALLY_FULFILLED = 100002
  SIMPLE_ORDER_FULFILLED = 100003
  SIMPLE_ORDER_UNFULFILLED = 100004
  before(:each) do
    # Toggle enabled to force reload of fixtures
    ShopifyAPI::Mock.enabled = false
    ShopifyAPI::Mock.enabled = true
    
    @user = Fabricate(:user, :id => 123)
  end

  it 'retrieves an order' do
    Shopify::Order.find(PREMIUM_ORDER_ID).should_not be_nil
  end
  
  it 'raises for non-existent orders' do
    WebMock.stub_request(:get, /myshopify\.com\/admin\/orders\/9999\.json/).
      to_return(:status => 404, :body => "", :headers => {})
    expect {
      Shopify::Order.find(9999)
    }.to raise_error(ActiveResource::ResourceNotFound)
  end

  it 'fulfills a simple premium order' do
    WebMock::stub_request(:post, /myshopify\.com\/admin\/orders\/450789469\/fulfillments.json/).
      with(:body => "{\"fulfillment\":{\"line_items\":[{\"id\":466157049,\"quantity\":1}]}}").
      to_return(:status => 200, :body => "", :headers => {})

    @user.premium?.should == false
    order = Shopify::Order.find(PREMIUM_ORDER_ID)
    order.process!
    @user.reload.premium?.should == true
    order.tags_contain?(Shopify::Order::ALL_BUT_JOULE_FULFILLED_TAG).should be_false
  end
  
  it 'fulfills a simple joule order' do
    # Not stubbing fulfillment call since this is not made for joule
    WebMock::stub_request(:put, /myshopify.com\/admin\/orders\/4507800.json/).
      to_return(:status => 200, :body => "", :headers => {})
    @user.premium?.should == false
    order = Shopify::Order.find(JOULE_ORDER_ID)
    order.process!
    @user.reload.premium?.should == true
    order.tags_contain?(Shopify::Order::ALL_BUT_JOULE_FULFILLED_TAG).should be_true
  end  

  it 'knows whether an order contains a tag' do
    order = Shopify::Order.find(JOULE_ORDER_ID)
    expect(order.tags_contain?('not-a-tag')).to be_false
    expect(order.tags_contain?('tag-one')).to be_true
  end
  
  it 'it knows if all but joule has been fulfilled' do
    expect(Shopify::Order.find(SIMPLE_ORDER_ALL_BUT_JOULE).all_but_joule_fulfilled?).to be_true
    expect(Shopify::Order.find(SIMPLE_ORDER_FULFILLED).all_but_joule_fulfilled?).to be_true
    expect(Shopify::Order.find(SIMPLE_ORDER_PARTIALLY_FULFILLED).all_but_joule_fulfilled?).to be_false
    expect(Shopify::Order.find(SIMPLE_ORDER_UNFULFILLED).all_but_joule_fulfilled?).to be_false
  end
end
