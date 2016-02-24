require 'spec_helper'

describe ShopifyOrderProcessor do
  before :each do
    # Toggle enabled to force reload of fixtures
    ShopifyAPI::Mock.enabled = false
    ShopifyAPI::Mock.enabled = true

    @op = ShopifyOrderProcessor
  end

  it 'should work process an existing order' do
    Shopify::Order.any_instance.should_receive(:process!)
    @op.perform(450789469)
  end
  
  it 'should throw for non-existent order' do
    Shopify::Order.should_receive(:find).and_throw(ActiveResource::ResourceNotFound)
    expect { @op.perform(111) }.to raise_error
  end
end
