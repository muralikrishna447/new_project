
describe Api::V0::WebhooksController do
  context 'POST /webhooks/shopify' do
    let(:order_id) { 123 }

    it 'handles an order_paid notification' do
      Resque.should_receive(:enqueue).with(ShopifyOrderProcessor, order_id)
      post :shopify, type: 'order_paid', id: order_id
      expect(response.status).to eq(200)
    end

    it 'handles an order_created notification' do
      Resque.should_receive(:enqueue).with(PremiumOrderProcessor, order_id)
      post :shopify, type: 'order_created', id: order_id
      expect(response.status).to eq(200)
    end
    
    it 'handles an invalid notification type' do
      Resque.should_not_receive(:enqueue)
      post :shopify, type: 'invalid'
      expect(response.status).to eq(400)
    end
  end
end
