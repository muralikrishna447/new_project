require 'spec_helper'

describe Shopify::Customer do
  context 'syncing and retrieving' do
    before(:each) do
      @user = Fabricate(:user, :id => 123, :email => 'me@example.org')
      @user_not_in_shopify = Fabricate(:user, :id => 456, :email => 'me2@example.org')

      @user_in_shopify_without_multipass = Fabricate(:user, :id => 789, :email => 'specialme@example.org')
      customer_data = [JSON.parse(ShopifyAPI::Mock::Fixture.find('customers').data)['customers'][0]]
      WebMock.stub_request(:get, /\.com\/admin\/customers\/search.json\?query=email:%22me@example.org%22/).
           to_return(:status => 200, :body => customer_data.to_json, :headers => {})

      customer_data = [JSON.parse(ShopifyAPI::Mock::Fixture.find('customers').data)['customers'][1]]
      WebMock.stub_request(:get, /\.com\/admin\/customers\/search.json\?query=email:%22specialme@example.org%22/).
           to_return(:status => 200, :body => customer_data.to_json, :headers => {})

    end

    it 'retrieves a customer' do
      # TODO - make it easier to load fixture data!
      customer_data = [JSON.parse(ShopifyAPI::Mock::Fixture.find('customers').data)['customers'][0]]
      puts customer_data.inspect
      WebMock.stub_request(:get, /\.com\/admin\/customers\/search.json\?query=email:%22me@example.org%22/).
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

    it 'syncs non-premium customers' do
      shopify_customer = Shopify::Customer.find_for_user @user
      shopify_customer.sync_tags!
      # expect no calls since no tags to sync
    end

    it 'creates user when it does not exist' do
      WebMock.stub_request(:get, /\.com\/admin\/customers\/search.json\?query=email:%22me2@example.org%22/).
        to_return(:status => 200, :body => "[]", :headers => {})
      WebMock.stub_request(:post, /\.com\/admin\/customers.json/).
        with(:body => "{\"customer\":{\"email\":\"me2@example.org\",\"multipass_identifier\":456}}").
        to_return(:status => 200, :body => '{"customer": {"id": 1073339463,"tags":""}}', :headers => {})

      Shopify::Customer.sync_user(@user_not_in_shopify)
    end

    it 'syncs an existing user' do
      WebMock.stub_request(:put, /\.com\/admin\/customers\/207119551.json/).
        to_return(:status => 200, :body => "", :headers => {})

      @user.make_premium_member(10)
      shopify_customer = Shopify::Customer.sync_user @user
    end
  end

  context 'email change' do
    before(:each) do
      customer_data = [JSON.parse(ShopifyAPI::Mock::Fixture.find('customers').data)['customers'][2]]
      WebMock.stub_request(:get, /\.com\/admin\/customers\/search.json\?query=email:%22old@chefsteps.com%22/).
           to_return(:status => 200, :body => customer_data.to_json, :headers => {})
    end

    it 'handles case where email is already updated' do
      @user = Fabricate(:user, :id => 112, :email => 'old@chefsteps.com')
      Shopify::Customer.update_email(@user, 'old@chefsteps.com')
      # No webmock calls mocked so shopify save cannot be called
    end

    it 'handles case where email us unepectedly different' do
      customer_data = [JSON.parse(ShopifyAPI::Mock::Fixture.find('customers').data)['customers'][0]]
      WebMock.stub_request(:get, /\.com\/admin\/customers\/search.json\?query=email:%22notold@chefsteps.com%22/).
           to_return(:status => 200, :body => customer_data.to_json, :headers => {})

      @user = Fabricate(:user, :id => 112, :email => 'new@chefsteps.com')
      expect { Shopify::Customer.update_email(@user, 'notold@chefsteps.com') }.to raise_error
    end

    it 'updates email address' do
      stub_put(207119552)
      @user = Fabricate(:user, :id => 112, :email => 'new@chefsteps.com')
      Shopify::Customer.update_email(@user, 'old@chefsteps.com')
    end
  end

  context 'referral code' do
    it 'just returns code if it already exists' do
      @user = Fabricate :user, :id => 112, :email => 'blah@chefsteps.com', referral_code: 'andre_3000'
      expect(Shopify::Customer.find_or_create_referral_code_for_user @user).to eq 'andre_3000'
    end

    it 'creates, stores, and syncs referral code if it doesnt exist' do
      @user = Fabricate :user, :id => 112, :email => 'blah@chefsteps.com'
      referral_code = 'sharejoule-xyzzy'
      SecureRandom.stub(:urlsafe_base64).and_return('xyzzy')
      WebMock.stub_request(:post, "https://123:321@test.myshopify.com/admin/discounts.json").
        with(:body => "{\"discount\":{\"code\":\"#{referral_code}\",\"discount_type\":\"fixed_amount\",\"value\":\"20.00\",\"usage_limit\":5,\"applies_to_resource\":\"product\",\"applies_to_id\":\"99999999\"}}",
             :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/json', 'User-Agent'=>'ShopifyAPI/4.2.2 ActiveResource/3.2.16 Ruby/2.1.10'}).
        to_return(:status => 200, :body => "", :headers => {})

      expect(Shopify::Customer.find_or_create_referral_code_for_user @user).to eq referral_code
      expect(@user.referral_code).to eq referral_code
    end
  end

  def stub_put(id='207119551')
    WebMock.stub_request(:put, /\.com\/admin\/customers\/#{id}.json/).
      to_return(:status => 200, :body => "", :headers => {})
  end
end
