require 'spec_helper'

describe Shopify::Customer do  
  before(:each) do
    # Toggle enabled to force reload of fixtures
    ShopifyAPI::Mock.enabled = false
    ShopifyAPI::Mock.enabled = true
    
    @user = Fabricate(:user, :id => 123, :email => 'me@example.org')
    @user_not_in_shopify = Fabricate(:user, :id => 456, :email => 'me2@example.org')
    
    customer_data = [JSON.parse(ShopifyAPI::Mock::Fixture.find('customers').data)['customers'][0]]
    WebMock.stub_request(:get, "https://123:321@chefsteps-staging.myshopify.com/admin/customers/search.json?query=email:me@example.org").
         to_return(:status => 200, :body => customer_data.to_json, :headers => {})
  end

  it 'retrieves a customer' do
    # TODO - make it easier to load fixture data!
    customer_data = [JSON.parse(ShopifyAPI::Mock::Fixture.find('customers').data)['customers'][0]]

    WebMock.stub_request(:get, "https://123:321@chefsteps-staging.myshopify.com/admin/customers/search.json?query=email:me@example.org").
         to_return(:status => 200, :body => customer_data.to_json, :headers => {})
    Shopify::Customer.find_for_user @user
  end

  it 'syncs the premium tag' do
    stub_put
    @user.make_premium_member(10)
    @user.use_premium_discount
    shopify_customer = Shopify::Customer.find_for_user @user
    shopify_customer.sync_tags!
    shopify_customer.tags.sort.should eq [Shopify::Customer::PREMIUM_MEMBER_TAG]
  end
  
  it 'syncs the joule premium discount tag' do
    stub_put

    @user.make_premium_member(10)
    shopify_customer = Shopify::Customer.find_for_user @user
    shopify_customer.sync_tags!
    shopify_customer.tags.sort.should eq [Shopify::Customer::JOULE_PREMIUM_DISCOUNT_TAG, Shopify::Customer::PREMIUM_MEMBER_TAG]
  end
  
  it 'does not save when no tag to sync' do
    shopify_customer = Shopify::Customer.find_for_user @user
    shopify_customer.sync_tags!
    # expect no calls since no tags to sync
  end
  
  it 'creates user when it does not exist' do
    WebMock.stub_request(:get, "https://123:321@chefsteps-staging.myshopify.com/admin/customers/search.json?query=email:me2@example.org").
      to_return(:status => 200, :body => "[]", :headers => {})
    WebMock.stub_request(:post, "https://123:321@chefsteps-staging.myshopify.com/admin/customers.json").
      with(:body => "{\"customer\":{\"email\":\"me2@example.org\",\"multipass_identifier\":456}}").
      to_return(:status => 200, :body => "", :headers => {})

    Shopify::Customer.sync_user(@user_not_in_shopify)
  end
  
  it 'syncs an existing user' do
    WebMock.stub_request(:put, "https://123:321@chefsteps-staging.myshopify.com/admin/customers/207119551.json").
      to_return(:status => 200, :body => "", :headers => {})

    @user.make_premium_member(10)
    shopify_customer = Shopify::Customer.sync_user @user
  end
  
  def stub_put
    WebMock.stub_request(:put, "https://123:321@chefsteps-staging.myshopify.com/admin/customers/207119551.json").
      to_return(:status => 200, :body => "", :headers => {})
  end
end