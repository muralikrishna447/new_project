require 'spec_helper'

describe Fulfillment::FbaShipmentProcessor do
  describe 'perform' do
    let(:order_1) { ShopifyAPI::Order.new(id: 1) }
    let(:order_2) { ShopifyAPI::Order.new(id: 2) }
    let(:params) { { 'my_param' => true } }
    let(:symbolized_params) { { my_param: true } }

    it 'processes open orders' do
      Shopify::Utils
        .stub(:search_orders_with_each)
        .with(status: 'open')
        .and_yield(order_1)
        .and_yield(order_2)
      Fulfillment::FbaShipmentProcessor.should_receive(:process_order).with(order_1, symbolized_params)
      Fulfillment::FbaShipmentProcessor.should_receive(:process_order).with(order_2, symbolized_params)
      Fulfillment::FbaShipmentProcessor.perform(params)
    end
  end

  describe 'process_order' do
    let(:line_item) { ShopifyAPI::LineItem.new(id: 'my-line-item-id', sku: sku) }
    let(:line_items) { [line_item] }
    let(:fulfillment) do
      ShopifyAPI::Fulfillment.new(
        line_items: line_items,
        status: fulfillment_status
      )
    end
    let(:order) do
      ShopifyAPI::Order.new(
        id: 'my-order-id',
        fulfillments: [fulfillment],
        line_items: line_items,
        tags: tags
      )
    end
    let(:tags) { '' }

    context 'item SKU is fulfillable by FBA' do
      let(:sku) { 'cs30001' }
      let(:seller_fulfillment_order_id) { 'my-fba-order-id' }

      context 'item has opened fulfillment' do
        let(:fulfillment_status) { 'open' }

        before :each do
          Fulfillment::Fba
            .stub(:seller_fulfillment_order_id)
            .with(order, fulfillment)
            .and_return(seller_fulfillment_order_id)
        end

        context 'item has FBA fulfillment order' do
          let(:fba_fulfillment_order) do
            {
              'SellerFulfillmentOrderId' => seller_fulfillment_order_id,
              'FulfillmentOrderStatus' => fba_status
            }
          end
          let(:fba_response) { { 'FulfillmentOrder' => fba_fulfillment_order } }

          before :each do
            Fulfillment::Fba
              .stub(:fulfillment_order_by_id)
              .with(seller_fulfillment_order_id)
              .and_return(fba_response)
          end

          context 'FBA status is pending' do
            shared_examples 'fba_shipment_pending' do
              it 'does not call to_shipment' do
                Fulfillment::FbaShipmentProcessor.should_not_receive(:to_shipment)
                Fulfillment::FbaShipmentProcessor.process_order(order)
              end
            end

            context 'FBA status is RECEIVED' do
              let(:fba_status) { 'RECEIVED' }
              include_examples 'fba_shipment_pending'
            end

            context 'FBA status is PLANNING' do
              let(:fba_status) { 'PLANNING' }
              include_examples 'fba_shipment_pending'
            end

            context 'FBA status is PROCESSING' do
              let(:fba_status) { 'PROCESSING' }
            end
          end

          context 'FBA status is cancelled' do
            let(:fba_status) { 'CANCELLED' }
            it 'does not call to_shipment' do
              Fulfillment::FbaShipmentProcessor.should_not_receive(:to_shipment)
              Fulfillment::FbaShipmentProcessor.process_order(order)
            end
          end

          context 'FBA status is complete' do
            let(:fba_status) { 'COMPLETE' }
            let(:params) { { complete_fulfillment: complete_fulfillment } }
            let(:shipment) { double('shipment') }

            context 'complete_fulfillment param is falsey' do
              let(:complete_fulfillment) { false }

              it 'calls to_shipment and does not complete fulfillment' do
                Fulfillment::FbaShipmentProcessor
                  .should_receive(:to_shipment)
                  .with(fba_response, order, fulfillment)
                  .and_return(shipment)
                shipment.should_not_receive(:complete!)
                Fulfillment::FbaShipmentProcessor.process_order(order, params)
              end
            end

            context 'complete_fulfillment param is truthy' do
              let(:complete_fulfillment) { true }
              let(:shipment) { double('shipment') }

              it 'calls to_shipment and completes fulfillment' do
                Fulfillment::FbaShipmentProcessor
                  .should_receive(:to_shipment)
                  .with(fba_response, order, fulfillment)
                  .and_return(shipment)
                shipment.should_receive(:complete!)
                Fulfillment::FbaShipmentProcessor.process_order(order, params)
              end
            end
          end

          context 'FBA status is error' do
            shared_examples 'fba_shipment_error' do
              context 'order has shipping-error tag' do
                let(:tags) { Fulfillment::FbaShipmentProcessor::SHIPPING_ERROR_TAG }

                it 'does not save order' do
                  Shopify::Utils.should_not_receive(:send_assert_true).with(order, :save)
                end
              end

              context 'order does not have shipping-error tag' do
                let(:tags) { 'some-other-tag' }
                let(:note_attributes) { double('note_attributes') }

                before :each do
                  order.stub(:note_attributes).and_return(note_attributes)
                end

                it 'does not call to_shipment and adds shipment-error tag' do
                  Fulfillment::FbaShipmentProcessor.should_not_receive(:to_shipment)
                  Shopify::Utils.should_receive(:add_to_order_tags).with(order, Fulfillment::FbaShipmentProcessor::SHIPPING_ERROR_TAG)
                  note_attributes.should_receive(:push).with(
                    ShopifyAPI::NoteAttribute.new(
                      name: Fulfillment::FbaShipmentProcessor::SHIPPING_ERROR_MSG_ATTR,
                      value: "FBA status is #{fba_status}"
                    )
                  )
                  Shopify::Utils.should_receive(:send_assert_true).with(order, :save)
                  Fulfillment::FbaShipmentProcessor.process_order(order)
                end
              end
            end

            context 'FBA status is INVALID' do
              let(:fba_status) { 'INVALID' }
              include_examples 'fba_shipment_error'
            end

            context 'FBA status is COMPLETE_PARTIALLED' do
              let(:fba_status) { 'COMPLETE_PARTIALLED' }
              include_examples 'fba_shipment_error'
            end

            context 'FBA status is UNFULFILLABLE' do
              let(:fba_status) { 'UNFULFILLABLE' }
              include_examples 'fba_shipment_error'
            end

            context 'FBA status is unknown state' do
              let(:fba_status) { 'unknown' }
              include_examples 'fba_shipment_error'
            end
          end
        end

        context 'item has no FBA fulfillment order' do
          before :each do
            Fulfillment::Fba
              .stub(:fulfillment_order_by_id)
              .with(seller_fulfillment_order_id)
              .and_return(nil)
          end

          it 'does not call to_shipment' do
            Fulfillment::FbaShipmentProcessor.should_not_receive(:to_shipment)
            Fulfillment::FbaShipmentProcessor.process_order(order)
          end
        end
      end

      context 'item does not have opened fulfillment' do
        let(:fulfillment_status) { 'success' }
        it 'does not look up fulfillment order' do
          Fulfillment::Fba.should_not_receive(:fulfillment_order)
          Fulfillment::FbaShipmentProcessor.process_order(order)
        end
      end
    end

    context 'item SKU is not fulfillable by FBA' do
      let(:sku) { 'not fba sku' }
      let(:fulfillment_status) { 'open' }
      it 'does not look up fulfillment order' do
        Fulfillment::Fba.should_not_receive(:fulfillment_order)
        Fulfillment::FbaShipmentProcessor.process_order(order)
      end
    end
  end

  describe 'to_shipment' do
    let(:fulfillment) { ShopifyAPI::Fulfillment.new(id: 1) }
    let(:order) do
      ShopifyAPI::Order.new(
        id: 2,
        fulfillments: [fulfillment]
      )
    end
    let(:carrier_code) { 'USPS' }
    let(:tracking_number_1) { '111' }
    let(:tracking_number_2) { '222' }
    let(:tracking_number_3) { '333' }
    let(:amazon_shipment_id_1) { 'my_amazon_shipment_id_1' }
    let(:amazon_shipment_id_2) { 'my_amazon_shipment_id_2' }
    let(:fba_response) do
      {
        'FulfillmentOrder' => {
          'SellerFulfillmentOrderId' => 'my-fba-order-id'
        },
        'FulfillmentShipment' => {
          'member' => fulfillment_shipment_response
        }
      }
    end

    before :each do
      Fulfillment::FbaShipmentProcessor.stub(:reduce_carrier_codes).and_return(carrier_code)
    end

    context 'fulfillment order has one shipment with status SHIPPED' do
      let(:fulfillment_shipment_response) do
        [
          {
            'AmazonShipmentId' => amazon_shipment_id_1,
            'FulfillmentShipmentStatus' => 'SHIPPED',
            'FulfillmentShipmentPackage' => {
              'member' => {
                'CarrierCode' => carrier_code,
                'TrackingNumber' => tracking_number_1
              }
            }
          },
          {
            'AmazonShipmentId' => amazon_shipment_id_2,
            'FulfillmentShipmentStatus' => 'CANCELLED_BY_FULFILLER',
            'FulfillmentShipmentPackage' => {
              'member' => {
                'CarrierCode' => carrier_code,
                'TrackingNumber' => tracking_number_2
              }
            }
          }
        ]
      end

      it 'returns shipment info for shipment with status SHIPPED' do
        expect(Fulfillment::FbaShipmentProcessor.to_shipment(fba_response, order, fulfillment))
          .to eq Fulfillment::Shipment.new(
            order: order,
            fulfillments: [fulfillment],
            tracking_company: carrier_code,
            tracking_numbers: [tracking_number_1],
            tracking_urls: ["https://www.swiship.com/t/#{amazon_shipment_id_1}"]
          )
      end
    end

    context 'fulfillment order has multiple shipments with status SHIPPED' do
      let(:fulfillment_shipment_response) do
        [
          {
            'AmazonShipmentId' => amazon_shipment_id_1,
            'FulfillmentShipmentStatus' => 'SHIPPED',
            'FulfillmentShipmentPackage' => {
              'member' => {
                'CarrierCode' => carrier_code,
                'TrackingNumber' => tracking_number_1
              }
            }
          },
          {
            'AmazonShipmentId' => amazon_shipment_id_2,
            'FulfillmentShipmentStatus' => 'SHIPPED',
            'FulfillmentShipmentPackage' => {
              'member' => {
                'CarrierCode' => carrier_code,
                'TrackingNumber' => tracking_number_2
              }
            }
          }
        ]
      end

      it 'returns shipment info for all shipments' do
        expect(Fulfillment::FbaShipmentProcessor.to_shipment(fba_response, order, fulfillment))
          .to eq Fulfillment::Shipment.new(
            order: order,
            fulfillments: [fulfillment],
            tracking_company: carrier_code,
            tracking_numbers: [tracking_number_1, tracking_number_2],
            tracking_urls: [
              "https://www.swiship.com/t/#{amazon_shipment_id_1}",
              "https://www.swiship.com/t/#{amazon_shipment_id_2}"
            ]
          )
      end
    end

    context 'fulfillment order has shipment with status SHIPPED with multiple packages' do
      let(:fulfillment_shipment_response) do
        [
          {
            'AmazonShipmentId' => amazon_shipment_id_1,
            'FulfillmentShipmentStatus' => 'SHIPPED',
            'FulfillmentShipmentPackage' => {
              'member' => [
                {
                  'CarrierCode' => carrier_code,
                  'TrackingNumber' => tracking_number_1
                },
                {
                  'CarrierCode' => carrier_code,
                  'TrackingNumber' => tracking_number_2
                }
              ]
            }
          }
        ]
      end

      it 'returns shipment info for all packages' do
        expect(Fulfillment::FbaShipmentProcessor.to_shipment(fba_response, order, fulfillment))
          .to eq Fulfillment::Shipment.new(
            order: order,
            fulfillments: [fulfillment],
            tracking_company: carrier_code,
            tracking_numbers: [tracking_number_1, tracking_number_2],
            tracking_urls: [
              # In this case we expect the same tracking URL for each
              # package as it is all part of the same top-level shipment.
              "https://www.swiship.com/t/#{amazon_shipment_id_1}",
              "https://www.swiship.com/t/#{amazon_shipment_id_1}"
            ]
          )
      end
    end

    context 'fulfillment order has no shipments with status SHIPPED' do
      let(:fulfillment_shipment_response) do
        [
          {
            'AmazonShipmentId' => amazon_shipment_id_1,
            'FulfillmentShipmentStatus' => 'CANCELLED_BY_FULFILLER'
          },
          {
            'AmazonShipmentId' => amazon_shipment_id_2,
            'FulfillmentShipmentStatus' => 'CANCELLED_BY_FULFILLER'
          }
        ]
      end

      it 'raises exception' do
        expect { Fulfillment::FbaShipmentProcessor.to_shipment(fba_response, order, fulfillment) }.to raise_error
      end
    end
  end

  describe 'reduce_carrier_codes' do
    let(:carrier_code) { 'USPS' }

    context 'multiple unique carrier codes' do
      it 'returns first carrier code' do
        expect(Fulfillment::FbaShipmentProcessor.reduce_carrier_codes([carrier_code, 'Other carrier']))
          .to eq carrier_code
      end
    end

    context 'single carrier code' do
      it 'returns carrier code' do
        expect(Fulfillment::FbaShipmentProcessor.reduce_carrier_codes([carrier_code, carrier_code]))
          .to eq carrier_code
      end

      context 'carrier code is Amazon Logistics' do
        let(:carrier_code) { 'Amazon Logistics' }
        it 'returns Amazon Logistics US' do
          expect(Fulfillment::FbaShipmentProcessor.reduce_carrier_codes([carrier_code]))
            .to eq 'Amazon Logistics US'
        end
      end
    end

    context 'carrier codes is empty' do
      it 'returns nil' do
        expect(Fulfillment::FbaShipmentProcessor.reduce_carrier_codes([])).to be_nil
      end
    end
  end

  describe 'response_to_array' do
    let(:order) { ShopifyAPI::Order.new(id: 1) }
    context 'response is a hash' do
      let(:response) { { 'key' => 'value' } }
      it 'returns the hash inside an array' do
        expect(Fulfillment::FbaShipmentProcessor.response_to_array(response, order)).to eq [response]
      end
    end

    context 'response is an array' do
      let(:response) { [{ 'key' => 'value' }] }
      it 'returns the array' do
        expect(Fulfillment::FbaShipmentProcessor.response_to_array(response, order)).to eq response
      end
    end

    context 'response is not a hash nor array' do
      let(:response) { 'bad' }
      it 'raises exception' do
        expect { Fulfillment::FbaShipmentProcessor.response_to_array(response, order) }.to raise_error
      end
    end
  end
end
