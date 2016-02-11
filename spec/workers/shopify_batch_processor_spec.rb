require 'spec_helper'

describe ShopifyBatchProcessor do
  before :each do
    # Toggle enabled to force reload of fixtures
    ShopifyAPI::Mock.enabled = false
    ShopifyAPI::Mock.enabled = true

    @bp = ShopifyBatchProcessor.new
  end

  it 'should record the success metric' do
    Librato::Metrics.should_receive(:submit).with('shopify.batch-processor.success' => 1)
    Shopify::Order.any_instance.stub(:process!)
    @bp.run()
  end
end
