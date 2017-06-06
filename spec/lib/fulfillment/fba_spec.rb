require 'spec_helper'

describe Fulfillment::Fba do
  describe 'seller_fulfillment_order_id' do
    let(:order_id) { 'my-order-id' }
    let(:item) { ShopifyAPI::LineItem.new(id: 'my-item-id') }
    let(:fulfillable) do
      Fulfillment::Fulfillable.new(
        order: ShopifyAPI::Order.new(
          id: order_id,
          line_items: [item],
          fulfillments: fulfillments
        )
      )
    end
    let(:fulfillment_id) { 'my-fulfillment-id' }

    context 'order has opened fulfillment for item' do
      let(:fulfillments) do
        [
          ShopifyAPI::Fulfillment.new(
            id: fulfillment_id,
            line_items: [item],
            status: 'open'
          )
        ]
      end
      it 'returns fulfillment order id' do
        expect(Fulfillment::Fba.seller_fulfillment_order_id(fulfillable, item)).to eq \
          "#{order_id}-#{fulfillment_id}"
      end
    end
    context 'order has no opened fulfillment for item' do
      let(:fulfillments) { [] }
      it 'raises error' do
        expect { Fulfillment::Fba.seller_fulfillment_order_id(fulfillable, item) }.to raise_error
      end
    end
  end

  describe 'displayable_order_id' do
    let(:order_name) { 'my-order-name' }
    let(:item) { ShopifyAPI::LineItem.new(id: 'my-item-id') }
    let(:fulfillable) do
      Fulfillment::Fulfillable.new(
        order: ShopifyAPI::Order.new(
          id: 'my-order-id',
          name: order_name,
          line_items: [item],
          fulfillments: fulfillments
        )
      )
    end
    let(:fulfillment_id) { 'my-fulfillment-id' }

    context 'order has opened fulfillment for item' do
      let(:fulfillments) do
        [
          ShopifyAPI::Fulfillment.new(
            id: fulfillment_id,
            line_items: [item],
            status: 'open'
          )
        ]
      end
      it 'returns displayable order id' do
        expect(Fulfillment::Fba.displayable_order_id(fulfillable, item)).to eq \
          "#{order_name}-#{fulfillment_id}"
      end
    end

    context 'order has no opened fulfillment for item' do
      let(:fulfillments) { [] }
      it 'raises error' do
        expect { Fulfillment::Fba.displayable_order_id(fulfillable, item) }.to raise_error
      end
    end
  end

  describe 'fulfillment_order' do
    let(:seller_fulfillment_order_id) { 'my-test-id' }

    context 'fulfillment order exists' do
      let(:fulfillment_order) { { 'SellerFulfillmentOrderId' => seller_fulfillment_order_id } }
      before :each do
        client = double('mws_client')
        response = double('response')
        response.stub(:parse).and_return(fulfillment_order)
        client.stub(:get_fulfillment_order).with(seller_fulfillment_order_id).and_return(response)
        MWS::FulfillmentOutboundShipment::Client.stub(:new).and_return(client)
        MWS::FulfillmentInventory::Client.stub(:new)
        Fulfillment::Fba.configure({})
      end

      it 'returns FBA fulfillment order' do
        expect(Fulfillment::Fba.fulfillment_order(seller_fulfillment_order_id)).to eq fulfillment_order
      end
    end

    context 'excon returns bad request' do
      let(:response) { double('response') }
      before :each do
        client = double('mws_client')
        response.stub(:[]).with(:status).and_return(400)
        error = Excon::Errors.status_error({ expects: 200 }, response)
        client.stub(:get_fulfillment_order).with(seller_fulfillment_order_id).and_raise(error)
        MWS::FulfillmentOutboundShipment::Client.stub(:new).and_return(client)
        MWS::FulfillmentInventory::Client.stub(:new)
        Fulfillment::Fba.configure({})
      end

      context 'response message indicates fulfillment order does not exist' do
        before :each do
          response.stub(:message).and_return("Requested order '#{seller_fulfillment_order_id}' not found")
        end

        it 'returns nil' do
          expect(Fulfillment::Fba.fulfillment_order(seller_fulfillment_order_id)).to be_nil
        end
      end

      context 'response message is other' do
        before :each do
          response.stub(:message).and_return('Some other bad request message')
        end

        it 'raises error' do
          expect { Fulfillment::Fba.fulfillment_order(seller_fulfillment_order_id) }.to raise_error
        end
      end
    end
  end

  describe 'create_fulfillment_order' do
    let(:seller_fulfillment_order_id) { 'my-order-id' }
    let(:displayable_order_id) { 'my-displayable-order-id' }
    let(:shipping_name) { 'Homer Simpson' }
    let(:shipping_company) { 'Mr. Plow' }
    let(:shipping_address1) { '742 Evergreen Terrace' }
    let(:shipping_address2) { 'AAA' }
    let(:shipping_city) { 'Springfield' }
    let(:shipping_province_code) { 'MA' }
    let(:shipping_country_code) { 'US' }
    let(:shipping_zip) { '12345' }
    let(:shipping_phone) { '555-123-4567' }
    let(:quantity) { 2 }
    let(:sku) { 'my-fba-sku' }
    let(:processed_at) { '2017-06-06T01:20:30+00:00' }
    let(:line_item_id) { 'my-line-item-id' }
    let(:line_item) do
      ShopifyAPI::LineItem.new(
        id: line_item_id,
        quantity: quantity,
        fulfillable_quantity: quantity,
        sku: sku
      )
    end
    let(:fulfillable) do
      Fulfillment::Fulfillable.new(
        order: ShopifyAPI::Order.new(
          processed_at: processed_at,
          shipping_address: ShopifyAPI::ShippingAddress.new(
            name: shipping_name,
            company: shipping_company,
            address1: shipping_address1,
            address2: shipping_address2,
            city: shipping_city,
            province_code: shipping_province_code,
            country_code: shipping_country_code,
            zip: shipping_zip,
            phone: shipping_phone
          ),
          fulfillments: [
            ShopifyAPI::Fulfillment.new(
              line_items: [line_item],
              status: 'open',
              quantity: quantity
            )
          ]
        )
      )
    end
    let(:client) { double('mws_client') }

    before do
      Fulfillment::Fba
        .stub(:seller_fulfillment_order_id)
        .with(fulfillable, line_item)
        .and_return(seller_fulfillment_order_id)
      Fulfillment::Fba
        .stub(:displayable_order_id)
        .with(fulfillable, line_item)
        .and_return(displayable_order_id)
      MWS::FulfillmentOutboundShipment::Client.stub(:new).and_return(client)
      MWS::FulfillmentInventory::Client.stub(:new)
      Fulfillment::Fba.configure({})
    end

    it 'calls mws client to create fulfillment order' do
      client.should_receive(:create_fulfillment_order).with(
        seller_fulfillment_order_id,
        displayable_order_id,
        processed_at,
        Fulfillment::Fba::COMMENT,
        Fulfillment::Fba::SHIPPING_SPEED,
        {
          'Name' => shipping_name,
          'Line1' => shipping_address1,
          'City' => shipping_city,
          'StateOrProvinceCode' => shipping_province_code,
          'CountryCode' => shipping_country_code,
          'PostalCode' => shipping_zip,
          'PhoneNumber' => shipping_phone,
          'Line2' => shipping_address2,
          'Line3' => shipping_company
        },
        [
          {
            'SellerSKU' => line_item.sku,
            'SellerFulfillmentOrderItemId' => line_item.id,
            'Quantity' => quantity
          }
        ]
      )
      Fulfillment::Fba.create_fulfillment_order(fulfillable, line_item)
    end
  end

  describe 'inventory_for_sku' do
    let(:client) { double('mws_client') }
    let(:response) { double('mws_response') }
    let(:sku) { 'my-sku' }

    before :each do
      MWS::FulfillmentOutboundShipment::Client.stub(:new)
      MWS::FulfillmentInventory::Client.stub(:new).and_return(client)
      client.stub(:list_inventory_supply).with(seller_skus: [sku]).and_return(response)
      Fulfillment::Fba.configure({})
    end

    context 'response supply list is empty' do
      let(:list) { { 'InventorySupplyList' => {} } }
      before do
        response.stub(:parse).and_return(list)
      end

      it 'returns zero' do
        expect(Fulfillment::Fba.inventory_for_sku(sku)).to eq 0
      end
    end

    context 'response supply list has more than one detail' do
      let(:list) do
        {
          'InventorySupplyList' => {
            '1' => {
              'InStockSupplyQuantity' => '1'
            },
            '2' => {
              'InStockSupplyQuantity' => '2'
            }
          }
        }
      end
      before do
        response.stub(:parse).and_return(list)
      end

      it 'raises error' do
        expect { Fulfillment::Fba.inventory_for_sku(sku) }.to raise_error
      end
    end

    context 'response supply list has single detail' do
      let(:inventory_quantity) { 3 }
      let(:list) do
        {
          'InventorySupplyList' => {
            '1' => {
              'InStockSupplyQuantity' => inventory_quantity.to_s
            }
          }
        }
      end
      before do
        response.stub(:parse).and_return(list)
      end

      it 'returns in-stock supply quantity' do
        expect(Fulfillment::Fba.inventory_for_sku(sku)).to eq inventory_quantity
      end
    end
  end
end
