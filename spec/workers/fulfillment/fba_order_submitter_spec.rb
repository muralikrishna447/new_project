require 'spec_helper'

describe Fulfillment::FbaOrderSubmitter, :skip => 'true' do
  describe 'after_save' do
    let(:quantity) { 2 }
    let(:line_item) do
      ShopifyAPI::LineItem.new(
        id: 'my-line-item',
        sku: sku,
        fulfillable_quantity: quantity,
        quantity: quantity
      )
    end
    let(:fulfillable) do
      Fulfillment::Fulfillable.new(
        order: ShopifyAPI::Order.new(
          id: 'my-order-id',
          line_items: [line_item],
          fulfillments: [
            ShopifyAPI::Fulfillment.new(
              status: fulfillment_status,
              line_items: [line_item]
            )
          ]
        ),
        line_items: [line_item]
      )
    end
    let(:fulfillables) { [fulfillable] }

    context 'SKU is fulfillable by FBA' do
      let(:sku) { 'cs30001' }
      let(:seller_fulfillment_order_id) { 'my-order-id' }
      let(:fulfillment_status) { 'open' }

      before :each do
        Fulfillment::Fba
          .stub(:seller_fulfillment_order_id)
          .and_return(seller_fulfillment_order_id)
      end

      context 'item does not have open fulfillment' do
        let(:fulfillment_status) { 'success' }

        it 'raises error' do
          expect { Fulfillment::FbaOrderSubmitter.after_save(fulfillables, {}) }.to raise_error
        end
      end

      context 'FBA fulfillment order exists' do
        before do
          Fulfillment::Fba
            .stub(:fulfillment_order_by_id)
            .with(seller_fulfillment_order_id)
            .and_return('FulfillmentOrder' => { 'ReceivedDateTime' => 'submitted-time' })
        end

        it 'does not create FBA fulfillment order' do
          Fulfillment::Fba.should_not_receive(:create_fulfillment_order)
          Fulfillment::FbaOrderSubmitter.should_receive(:report_metrics).with(0, 0)
          Fulfillment::FbaOrderSubmitter.after_save(fulfillables, {})
        end
      end

      context 'FBA fulfillment order does not exist' do
        before do
          Fulfillment::Fba
            .stub(:fulfillment_order_by_id)
            .with(seller_fulfillment_order_id)
            .and_return(nil)
        end

        context 'create_fulfillment_order param is truthy' do
          it 'creates FBA fulfillment order' do
            Fulfillment::Fba
              .should_receive(:create_fulfillment_order)
              .with(fulfillable, line_item)
            Fulfillment::FbaOrderSubmitter.should_receive(:report_metrics).with(1, quantity)
            Fulfillment::FbaOrderSubmitter.after_save(fulfillables, create_fulfillment_orders: true)
          end
        end

        context 'create_fulfillment_order param is falsey' do
          it 'does not create FBA fulfillment order' do
            Fulfillment::Fba.should_not_receive(:create_fulfillment_order)
            Fulfillment::FbaOrderSubmitter.should_receive(:report_metrics).with(0, 0)
            Fulfillment::FbaOrderSubmitter.after_save(fulfillables, create_fulfillment_orders: false)
          end
        end
      end
    end

    context 'SKU is not fulfillable by FBA' do
      let(:sku) { 'other-sku' }
      it 'raises error' do
        expect { Fulfillment::FbaOrderSubmitter.after_save(fulfillables, {}) }.to raise_error
      end
    end
  end

  describe 'transform' do
    let(:quantity) { 4 }
    let(:line_item_id) { 'my-line-item' }
    let(:sku) { 'my-sku' }
    let(:line_item) do
      ShopifyAPI::LineItem.new(
        id: line_item_id,
        quantity: quantity,
        fulfillable_quantity: quantity,
        sku: sku
      )
    end
    let(:fulfillment_id) { 'my-fulfillment-id' }
    let(:fulfillment) do
      ShopifyAPI::Fulfillment.new(
        id: fulfillment_id,
        line_items: [line_item],
        status: fulfillment_status
      )
    end
    let(:order_id) { 'my-order-id' }
    let(:order) do
      ShopifyAPI::Order.new(
        id: order_id,
        line_items: [line_item],
        fulfillments: [fulfillment],
        name: 'my-order-name',
        processed_at: Time.now.utc.iso8601,
        shipping_address: {
          name: '',
          address1: '',
          address2: '',
          company: '',
          city: '',
          province_code: '',
          country_code: '',
          zip: '',
          phone: ''
        }
      )
    end
    let(:fulfillable) do
      Fulfillment::Fulfillable.new(
        line_items: [line_item],
        order: order
      )
    end

    before :each do
      fulfillable.should_receive(:reload!)
    end

    context 'line item has no opened fulfillment' do
      let(:fulfillment_status) { 'success' }

      it 'raises error' do
        expect { Fulfillment::FbaOrderSubmitter.transform(fulfillable) }.to raise_error
      end
    end

    context 'line item has opened fulfillment' do
      let(:fulfillment_status) { 'open' }

      it 'returns fulfillable line item as array' do
        result = Fulfillment::FbaOrderSubmitter.transform(fulfillable)
        expect(result[0][0]).to eq order_id
        expect(result[0][1]).to eq line_item_id
        expect(result[0][2]).to eq fulfillment_id
        expect(result[0][3]).to eq Fulfillment::Fba.seller_fulfillment_order_id(order, fulfillment)
        expect(result[0][4]).to eq Fulfillment::Fba.displayable_order_id(order, fulfillment)
        expect(result[0][17]).to eq sku
        expect(result[0][18]).to eq quantity
      end
    end
  end

  describe 'submit_orders_to_fba' do
    context 'sku is not specified' do
      it 'raises error' do
        expect { Fulfillment::FbaOrderSubmitter.submit_orders_to_fba({}) }.to raise_error
      end
    end

    context 'sku is not fulfillable by FBA' do
      it 'raises error' do
        expect { Fulfillment::FbaOrderSubmitter.submit_orders_to_fba(sku: 'bogus-sku') }.to raise_error
      end
    end

    shared_examples 'fba_submitter_perform' do
      let(:verified_job_params) do
        {
          quantity: quantity,
          skus: [sku],
          child_job_class: 'Fulfillment::FbaOrderSubmitter'
        }
      end

      context 'perform_inline param is truthy' do
        let(:perform_inline) { true }
        it 'calls perform inline' do
          Fulfillment::PendingOrderExporter
            .should_receive(:perform)
            .with(hash_including(verified_job_params))
          Fulfillment::FbaOrderSubmitter.submit_orders_to_fba(options)
        end
      end

      context 'perform_inline param is falsey' do
        let(:perform_inline) { false }
        it 'queues resque job' do
          Resque
            .should_receive(:enqueue)
            .with(Fulfillment::PendingOrderExporter, hash_including(verified_job_params))
          Fulfillment::FbaOrderSubmitter.submit_orders_to_fba(options)
        end
      end
    end

    context 'sku is fulfillable by FBA' do
      let(:sku) { 'cs30001' }
      let(:options) do
        {
          sku: sku,
          max_quantity: max_quantity,
          perform_inline: perform_inline
        }
      end

      context 'max_quantity param is specified' do
        let(:quantity) { 2 }
        let(:max_quantity) { quantity }

        before :each do
          Fulfillment::Fba.should_not_receive(:inventory_for_sku)
        end

        include_examples 'fba_submitter_perform'
      end

      context 'max_quantity param is not specified' do
        let(:quantity) { 5 }
        let(:max_quantity) { nil }

        before :each do
          Fulfillment::Fba.should_receive(:inventory_for_sku).with(sku).and_return(quantity)
        end

        include_examples 'fba_submitter_perform'
      end
    end
  end
end
