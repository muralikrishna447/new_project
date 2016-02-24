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
    stub_metafield_post('premium-member', true)
    stub_metafield_post('jp-discount-eligible', false)

    @user.make_premium_member(10)
    @user.use_premium_discount
    shopify_customer = Shopify::Customer.find_for_user @user
    shopify_customer.sync_metafields!
  end
  
  it 'syncs the joule premium discount tag' do
    stub_metafield_post('premium-member', true)
    stub_metafield_post('jp-discount-eligible', true)

    @user.make_premium_member(10)
    shopify_customer = Shopify::Customer.find_for_user @user
    shopify_customer.sync_metafields!
  end
  
  it 'syncs non-premium customers' do
    stub_metafield_post('premium-member', false)
    stub_metafield_post('jp-discount-eligible', false)

    shopify_customer = Shopify::Customer.find_for_user @user
    shopify_customer.sync_metafields!
  end

  it 'creates user when it does not exist' do
    WebMock.stub_request(:get, "https://123:321@chefsteps-staging.myshopify.com/admin/customers/search.json?query=email:me2@example.org").
      to_return(:status => 200, :body => "[]", :headers => {})
    WebMock.stub_request(:post, "https://123:321@chefsteps-staging.myshopify.com/admin/customers.json").
      with(:body => "{\"customer\":{\"email\":\"me2@example.org\",\"multipass_identifier\":456}}").
      to_return(:status => 200, :body => '{"customer": {"id": 1073339463}}', :headers => {})
    stub_metafield_post('premium-member', false)
    stub_metafield_post('jp-discount-eligible', false)

    Shopify::Customer.sync_user(@user_not_in_shopify)
  end
  
  it 'syncs an existing user' do
    WebMock.stub_request(:put, "https://123:321@chefsteps-staging.myshopify.com/admin/customers/207119551.json").
      to_return(:status => 200, :body => "", :headers => {})
    stub_metafield_post('premium-member', true)
    stub_metafield_post('jp-discount-eligible', true)

    @user.make_premium_member(10)
    shopify_customer = Shopify::Customer.sync_user @user
  end

  def stub_metafield_post(key, value)
    WebMock.stub_request(:post, /myshopify.com\/admin\/customers\/.*\/metafields.json/).
      with(:body => {:metafield => {:namespace => 'chefsteps', :key => key, :value_type => 'string',
          :value=>value}}.to_json).
      to_return(:status => 200, :body => "", :headers => {})
  end
end
