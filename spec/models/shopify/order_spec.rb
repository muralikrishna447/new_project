require 'spec_helper'

describe Shopify::Order do
  
  JOULE_ORDER_ID = 4507800  
  PREMIUM_ORDER_ID = 450789469
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
  end
  
  it 'fulfills a simple joule order' do
    # Not stubbing fulfillment call since this is not made for joule
    @user.premium?.should == false
    order = Shopify::Order.find(JOULE_ORDER_ID)
    order.process!
    @user.reload.premium?.should == true
  end
end
