require 'spec_helper'
require 'json'

describe Shipwire::Order do
  describe 'array_from_json' do
    let(:orders_json) { File.read(Rails.root.join('spec', 'api_responses', 'shipwire_orders_response_multiple.json')) }
    let(:holds) do
      [
        Shipwire::Hold.new(
          id: 724752,
          type: 'customer',
          sub_type: 'nomethod'
        )
      ]
    end

    it 'returns order array' do
      array = Shipwire::Order.array_from_json(orders_json)
      expect(array).to eq(
        [
          Shipwire::Order.new(
            id: 198651672,
            number: '#1288.1',
            status: 'delivered',
            trackings: [
              Shipwire::Tracking.new(
                number: '9400110200793110752954',
                carrier: 'USPS',
                url: 'https://tools.usps.com/go/TrackConfirmAction.action?tLabels=9400110200793110752954'
              )
            ],
            holds: holds
          ),
          Shipwire::Order.new(
            id: 198794572,
            number: '#1292.1',
            status: 'delivered',
            trackings: [
              Shipwire::Tracking.new(
                number: '9400110200793110752978',
                carrier: 'USPS',
                url: 'https://tools.usps.com/go/TrackConfirmAction.action?tLabels=9400110200793110752978'
              )
            ],
            holds: holds
          )
        ]
      )
    end
  end

  describe 'sync_to_shopify' do
    let(:line_item_id) { 1111 }
    let(:shopify_fulfillment_carrier) { nil }
    let(:shopify_tracking_numbers) { [] }
    let(:shopify_tracking_urls) { [] }
    let(:shopify_order_id) { 2222 }
    let(:shopify_order_name) { '#1234' }
    let(:shopify_order_tags) { '' }
    let(:line_items) do
      line_item = double('line_item')
      line_item.stub(:id) { line_item_id }
      line_item.stub(:sku) { 'cs10001' }
      [line_item]
    end
    let(:shopify_order) do
      shopify_order = double('shopify_order')
      shopify_order.stub(:id) { shopify_order_id }
      shopify_order.stub(:name) { shopify_order_name }
      shopify_order.stub(:line_items) { line_items }
      shopify_order.stub(:fulfillments) { shopify_fulfillments }
      shopify_order.stub(:tags) { shopify_order_tags }
      shopify_order.stub(:tags=)
      shopify_order.stub(:save)
      shopify_order
    end
    let(:shipwire_trackings) { [] }
    let(:shipwire_holds) { [] }
    let(:shipwire_order) do
      Shipwire::Order.new(
        id: 333,
        number: "#{shopify_order_name}.1",
        status: shipwire_fulfillment_status,
        trackings: shipwire_trackings,
        holds: shipwire_holds
      )
    end

    shared_examples 'sync_to_shopify' do
      it 'syncs shipwire order to shopify' do
        # We expect the Shopify order to be saved with tags if there are holds in Shipwire
        unless shipwire_holds.empty?
          shopify_order.should_receive(:save)
          shopify_order.should_receive(:tags=).with(expected_shopify_order_tags)
        end

        shipwire_order.sync_to_shopify(shopify_order)
      end

      it 'replaces shopify trackings with shipwire trackings' do
        if shipwire_trackings.empty?
          expect(shopify_fulfillment.respond_to?(:carrier)).to be_false
          expect(shopify_fulfillment.respond_to?(:tracking_numbers)).to be_false
          expect(shopify_fulfillment.respond_to?(:tracking_urls)).to be_false
        else
          expect(shopify_fulfillment.carrier.nil?).to be_false
          expect(shopify_fulfillment.tracking_numbers.length).to eq shipwire_trackings.length
          expect(shopify_fulfillment.tracking_urls.length).to eq shipwire_trackings.length
          shipwire_trackings.each_index do |i|
            expect(shopify_fulfillment.carrier).to eq(shipwire_trackings[i].carrier)
            expect(shopify_fulfillment.tracking_numbers[i]).to eq(shipwire_trackings[i].number)
            expect(shopify_fulfillment.tracking_urls[i]).to eq(shipwire_trackings[i].url)
          end
        end
      end
    end

    shared_examples 'all sync_to_shopify' do
      context 'shipwire order has trackings' do
        let(:carrier) { 'my carrier' }
        let(:shopify_fulfillment_carrier) { carrier }
        let(:tracking_number_1) { 'tracking number 1' }
        let(:tracking_number_2) { 'tracking number 2' }
        let(:tracking_url_1) { 'tracking_url_1' }
        let(:tracking_url_2) { 'tracking_url_2' }
        let(:shipwire_trackings) do
          [
            Shipwire::Tracking.new(
              number: tracking_number_1,
              carrier: carrier,
              url: tracking_url_1
            ),
            Shipwire::Tracking.new(
              number: tracking_number_2,
              carrier: carrier,
              url: tracking_url_2
            )
          ]
        end
        let(:shopify_tracking_numbers) do
          [tracking_number_1, tracking_number_2]
        end
        let(:shopify_tracking_urls) do
          [tracking_url_1, tracking_url_2]
        end

        include_examples 'sync_to_shopify'
      end

      context 'shipwire order has holds' do
        let(:shipwire_fulfillment_status) { 'held' }
        let(:shopify_fulfillment_status) { 'open' }
        let(:hold_type_1) { 'hold type 1' }
        let(:hold_type_2) { 'hold type 2' }
        let(:hold_sub_type_1) { 'hold sub_type 1' }
        let(:hold_sub_type_2) { 'hold sub_type 2' }
        let(:shipwire_holds) do
          [
            Shipwire::Hold.new(type: hold_type_1, sub_type: hold_sub_type_1),
            Shipwire::Hold.new(type: hold_type_2, sub_type: hold_sub_type_2)
          ]
        end
        let(:expected_shopify_order_tags) do
          "shipwire-held,shipwire-held-#{hold_type_1}-#{hold_sub_type_1},shipwire-held-#{hold_type_2}-#{hold_sub_type_2}"
        end

        include_examples 'sync_to_shopify'
      end

      context 'shipwire order has no trackings or holds' do
        include_examples 'sync_to_shopify'
      end
    end

    context 'shopify order has no joule fulfillment' do
      # This is what we expect the newly-created fulfillment to look like.
      let(:shopify_fulfillment) do
        fulfillment = ShopifyAPI::Fulfillment.new
        fulfillment.attributes[:line_items] = [{ id: line_item_id }]
        fulfillment.attributes[:status] = shopify_fulfillment_status
        if shopify_fulfillment_carrier
          fulfillment.attributes[:carrier] = shopify_fulfillment_carrier
        end
        unless shopify_tracking_numbers.empty?
          fulfillment.attributes[:tracking_numbers] = shopify_tracking_numbers
        end
        unless shopify_tracking_urls.empty?
          fulfillment.attributes[:tracking_urls] = shopify_tracking_urls
        end
        fulfillment
      end
      let(:shopify_fulfillments) { [] }

      # Stub out the request to Shopify to create the fulfillment with
      # the expected body for each request. The test fails if the request
      # body does not match the expected fulfillment.
      before :each do
        # This is kinda roundabout but seems to be the only way to get
        # a hash representation out of an ActiveResource object.
        body = JSON.parse(shopify_fulfillment.encode)
        WebMock
          .stub_request(:post, /myshopify.com\/admin\/orders\/#{shopify_order_id}\/fulfillments.json/)
          .with(body: body)
          .to_return(status: 200, body: '', headers: {})
      end

      context 'shipwire fulfillment status is complete' do
        let(:shipwire_fulfillment_status) { 'complete' }
        let(:shopify_fulfillment_status) { 'success' }
        include_examples 'all sync_to_shopify'
      end

      context 'shipwire fulfillment status is delivered' do
        let(:shipwire_fulfillment_status) { 'delivered' }
        let(:shopify_fulfillment_status) { 'success' }
        include_examples 'all sync_to_shopify'
      end

      context 'shipwire fulfillment status is submitted' do
        let(:shipwire_fulfillment_status) { 'submitted' }
        let(:shopify_fulfillment_status) { 'open' }
        include_examples 'all sync_to_shopify'
      end

      context 'shipwire fulfillment status is processed' do
        let(:shipwire_fulfillment_status) { 'processed' }
        let(:shopify_fulfillment_status) { 'open' }
        include_examples 'all sync_to_shopify'
      end

      context 'shopify order has no joule line item' do
        let(:shipwire_fulfillment_status) { 'processed' }
        let(:shopify_fulfillment_status) { 'open' }
        let(:line_items) { [] }
        it 'raises exception' do
          expect { shipwire_order.sync_to_shopify(shopify_order) }.to raise_error
        end
      end
    end

    context 'shopify order has existing joule fulfillment' do
      # This is the existing Joule fulfillment.
      let(:shopify_fulfillment_id) { 5555 }
      let(:shopify_fulfillment) do
        fulfillment = ShopifyAPI::Fulfillment.new
        fulfillment.attributes[:id] = shopify_fulfillment_id
        fulfillment.prefix_options[:order_id] = shopify_order_id
        line_item = ShopifyAPI::LineItem.new
        line_item.attributes[:id] = line_item_id
        line_item.attributes[:sku] = 'cs10001'
        fulfillment.attributes[:line_items] = [line_item]
        fulfillment.attributes[:status] = shopify_fulfillment_status
        if shopify_fulfillment_carrier
          fulfillment.attributes[:carrier] = shopify_fulfillment_carrier
        end
        unless shopify_tracking_numbers.empty?
          fulfillment.attributes[:tracking_numbers] = shopify_tracking_numbers
        end
        unless shopify_tracking_urls.empty?
          fulfillment.attributes[:tracking_urls] = shopify_tracking_urls
        end
        fulfillment
      end
      let(:shopify_fulfillments) { [shopify_fulfillment] }

      # Stub out the request to Shopify to update the fulfillment with
      # the expected body for each request. The test fails if the request
      # body does not match the expected fulfillment.
      before :each do
        # This is kinda roundabout but seems to be the only way to get
        # a hash representation out of an ActiveResource object.
        body = JSON.parse(shopify_fulfillment.encode)
        WebMock
          .stub_request(:put, /myshopify.com\/admin\/orders\/#{shopify_order_id}\/fulfillments\/#{shopify_fulfillment_id}.json/)
          .with(body: body)
          .to_return(status: 200, body: '', headers: {})
      end

      context 'shipwire has shipped the order' do
        # Stub out the request to Shopify to complete the fulfillment.
        before :each do
          WebMock
            .stub_request(:post, /myshopify.com\/admin\/orders\/#{shopify_order_id}\/fulfillments\/#{shopify_fulfillment_id}\/complete.json/)
            .to_return(status: 200, body: '', headers: {})
        end

        context 'shipwire fulfillment state is complete' do
          let(:shipwire_fulfillment_status) { 'complete' }
          let(:shopify_fulfillment_status) { 'success' }
          include_examples 'all sync_to_shopify'
        end

        context 'shipwire fulfillment state is delivered' do
          let(:shipwire_fulfillment_status) { 'delivered' }
          let(:shopify_fulfillment_status) { 'success' }
          include_examples 'all sync_to_shopify'
        end
      end

      context 'shipwire has not yet shipped the order' do
        context 'shipwire fulfillment state is submitted' do
          let(:shipwire_fulfillment_status) { 'submitted' }
          let(:shopify_fulfillment_status) { 'open' }
          include_examples 'all sync_to_shopify'
        end

        context 'shipwire fulfillment state is pending' do
          let(:shipwire_fulfillment_status) { 'pending' }
          let(:shopify_fulfillment_status) { 'open' }
          include_examples 'all sync_to_shopify'
        end
      end
    end
  end
end
