require 'spec_helper'

describe Fulfillment::Shipment do
  describe 'complete!' do
    let(:order_id) { 1 }
    let(:fulfillment_1) do
      fulfillment = ShopifyAPI::Fulfillment.new(id: 1)
      fulfillment.prefix_options[:order_id] = order_id
      fulfillment.attributes[:tracking_company] = fulfillment_1_tracking_company
      fulfillment.attributes[:tracking_numbers] = fulfillment_1_tracking_numbers
      fulfillment.attributes[:tracking_urls] = fulfillment_1_tracking_urls
      fulfillment
    end
    let(:fulfillment_2) do
      fulfillment = ShopifyAPI::Fulfillment.new(id: 2)
      fulfillment.prefix_options[:order_id] = order_id
      fulfillment.attributes[:tracking_company] = fulfillment_2_tracking_company
      fulfillment.attributes[:tracking_numbers] = fulfillment_2_tracking_numbers
      fulfillment.attributes[:tracking_urls] = fulfillment_2_tracking_urls
      fulfillment
    end
    let(:tracking_company) { 'my tracking company' }
    let(:tracking_numbers) { ['123', '456'] }
    let(:tracking_urls) { ['tracking_url_1', 'tracking_url_2'] }
    let(:shipment) do
      Fulfillment::Shipment.new(
        order: ShopifyAPI::Order.new(id: order_id, name: '#myordername'),
        fulfillments: [fulfillment_1, fulfillment_2],
        tracking_company: tracking_company,
        tracking_numbers: tracking_numbers,
        tracking_urls: tracking_urls
      )
    end

    context 'tracking has been updated' do
      let(:fulfillment_1_tracking_company) { tracking_company }
      let(:fulfillment_1_tracking_numbers) { tracking_numbers }
      let(:fulfillment_1_tracking_urls) { tracking_urls }
      let(:fulfillment_2_tracking_company) { tracking_company }
      let(:fulfillment_2_tracking_numbers) { tracking_numbers }
      let(:fulfillment_2_tracking_urls) { tracking_urls }

      it 'does not update tracking and completes all fulfillments' do
        stub_fulfillment_complete(order_id, fulfillment_1.id)
        stub_fulfillment_complete(order_id, fulfillment_2.id)
        Shopify::Utils
          .should_receive(:send_assert_true)
          .with(instance_of(ShopifyAPI::Fulfillment), :save)
          .twice
        Shopify::Utils
          .should_receive(:send_assert_true)
          .with(instance_of(ShopifyAPI::Fulfillment), :complete)
          .twice

        shipment.complete!
      end
    end

    context 'tracking has not been updated' do
      let(:fulfillment_1_tracking_company) { nil }
      let(:fulfillment_1_tracking_numbers) { [] }
      let(:fulfillment_1_tracking_urls) { [] }
      let(:fulfillment_2_tracking_company) { nil }
      let(:fulfillment_2_tracking_numbers) { [] }
      let(:fulfillment_2_tracking_urls) { [] }

      it 'updates tracking and completes all fulfillments' do
        stub_fulfillment_update(order_id, fulfillment_1.id, tracking_company, tracking_numbers, tracking_urls, false)
        stub_fulfillment_update(order_id, fulfillment_1.id, tracking_company, tracking_numbers, tracking_urls, true)
        stub_fulfillment_complete(order_id, fulfillment_1.id)

        stub_fulfillment_update(order_id, fulfillment_2.id, tracking_company, tracking_numbers, tracking_urls, false)
        stub_fulfillment_update(order_id, fulfillment_2.id, tracking_company, tracking_numbers, tracking_urls, true)
        stub_fulfillment_complete(order_id, fulfillment_2.id)

        Shopify::Utils
          .should_receive(:send_assert_true)
          .with(instance_of(ShopifyAPI::Fulfillment), :save)
          .exactly(4).times
        Shopify::Utils
          .should_receive(:send_assert_true)
          .with(instance_of(ShopifyAPI::Fulfillment), :complete)
          .twice

        shipment.complete!
      end
    end
  end

  def stub_fulfillment_update(order_id, fulfillment_id, tracking_company, tracking_numbers, tracking_urls, notify_customer)
    WebMock
      .stub_request(:put, /test.myshopify.com\/admin\/orders\/#{order_id}\/fulfillments\/#{fulfillment_id}.json/)
      .with(body: "{\"fulfillment\":{\"id\":#{fulfillment_id},\"tracking_company\":\"my tracking company\",\"tracking_numbers\":#{tracking_numbers.to_json},\"tracking_urls\":#{tracking_urls.to_json},\"notify_customer\":#{notify_customer}}}")
      .to_return(status: 200, body: '')
  end

  def stub_fulfillment_complete(order_id, fulfillment_id)
    WebMock
      .stub_request(:post, /test.myshopify.com\/admin\/orders\/#{order_id}\/fulfillments\/#{fulfillment_id}\/complete.json/)
      .with(body: '{}')
      .to_return(status: 200, body: '')
  end
end
