require 'spec_helper'

describe ShopifyBatchProcessor do
  before :each do
    # Toggle enabled to force reload of fixtures
    ShopifyAPI::Mock.enabled = false
    ShopifyAPI::Mock.enabled = true

    @bp = ShopifyBatchProcessor.new
  end

  it 'should record the success metric' do
    Librato.should_receive(:increment).with('shopify.batch-processor.success', sporadic: true)
    Shopify::Order.any_instance.stub(:process!)
    @bp.run()
  end
end
