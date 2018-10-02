require 'spec_helper'

#skipping per Shopify removal
describe ShopifyBatchProcessor, :skip => 'true' do
  before :each do
    # Toggle enabled to force reload of fixtures
    ShopifyAPI::Mock.enabled = false
    ShopifyAPI::Mock.enabled = true

    @bp = ShopifyBatchProcessor.new
  end

  it 'should record the success metric' do
    Librato.should_receive(:increment).with('shopify.batch-processor.success', sporadic: true)
    path = ShopifyAPI::Order.collection_path(:updated_at_min => 0, :limit => 100, :page => 0)
    orders = ShopifyAPI::Order.find(:all, :from => path)
    # ShopifyAPI mock doesn't handle pagination properly so return empty after first page
    ShopifyAPI::Order.stub(:find).and_return(orders, [])
    Shopify::Order.any_instance.stub(:process!)
    @bp.run()
  end
end
