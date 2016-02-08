
describe Api::V0::WebhooksController do
  context 'POST /webhooks/shopify' do
    it 'handles an order notification' do
      order_id = 123
      Resque.should_receive(:enqueue).with(ShopifyOrderProcessor, order_id)
      post :shopify, type: 'order', id: order_id
      expect(response.status).to eq(200)
    end
    
    it 'handles an order notification' do
      Resque.should_not_receive(:enqueue)
      post :shopify, type: 'invalid'
      expect(response.status).to eq(400)
    end
  end
end
