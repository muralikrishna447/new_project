require 'spec_helper'

describe Fulfillment::ShippingAddressValidator, :skip => 'true' do
  describe 'perform' do
    let(:order) { double('order') }
    let(:skus) { ['my_sku'] }

    context 'should_validate? returns true' do
      before :each do
        Fulfillment::ShippingAddressValidator
          .stub(:should_validate?)
          .with(order, skus)
          .and_return(true)
      end

      it 'calls validate on order and reports metrics' do
        Fulfillment::OrderCleaners.should_receive(:clean!).with(order)
        Shopify::Utils.should_receive(:search_orders_with_each).with(status: 'open').and_yield(order)
        Fulfillment::ShippingAddressValidator.should_receive(:validate).with(order).and_return(true)
        Librato.should_receive(:increment).with('fulfillment.address-validator.success', sporadic: true)
        Librato.should_receive(:increment).with('fulfillment.address-validator.valid.count', by: 1, sporadic: true)
        Librato.should_receive(:increment).with('fulfillment.address-validator.invalid.count', by: 0, sporadic: true)
        Fulfillment::ShippingAddressValidator.perform(skus)
      end
    end

    context 'should_validate? returns false' do
      before :each do
        Fulfillment::ShippingAddressValidator
          .stub(:should_validate?)
          .with(order, skus)
          .and_return(false)
      end

      it 'does not call validate on order' do
        Shopify::Utils.should_receive(:search_orders_with_each).with(status: 'open').and_yield(order)
        Fulfillment::ShippingAddressValidator.should_not_receive(:validate)
        Fulfillment::ShippingAddressValidator.perform(skus)
      end
    end
  end

  describe 'validate' do
    let(:order_id) { 1 }
    let(:order) do
      ShopifyAPI::Order.new(
        id: order_id,
        note_attributes: note_attributes,
        tags: tags
      )
    end

    context 'address is valid' do
      before :each do
        Fulfillment::FedexShippingAddressValidator.should_receive(:validate).and_return(is_valid: true)
      end

      context 'order has validation tag and note attribute' do
        let(:validation_note) do
          ShopifyAPI::NoteAttribute.new(
            name: Fulfillment::ShippingAddressValidator::VALIDATION_MESSAGE_NOTE_KEY,
            value: 'my message'
          )
        end
        let(:existing_note) do
          ShopifyAPI::NoteAttribute.new(
            name: 'foo',
            value: 'bar'
          )
        end
        let(:note_attributes) { [validation_note, existing_note] }
        let(:tags) { Fulfillment::ShippingAddressValidator::VALIDATION_ERROR_TAG }
        let(:updated_order) do
          ShopifyAPI::Order.new(
            id: order_id,
            note_attributes: [existing_note],
            tags: ''
          )
        end

        it 'removes tag and note and saves order' do
          Shopify::Utils.should_receive(:send_assert_true).with(updated_order, :save)
          expect(Fulfillment::ShippingAddressValidator.validate(order)).to be_true
        end
      end

      context 'order has no validation tag nor note attribute' do
        let(:note_attributes) { [] }
        let(:tags) { '' }

        it 'does not save order' do
          Shopify::Utils.should_not_receive(:send_assert_true).with(order, :save)
          expect(Fulfillment::ShippingAddressValidator.validate(order)).to be_true
        end
      end
    end

    context 'address is invalid' do
      before :each do
        Fulfillment::FedexShippingAddressValidator.should_receive(:validate).and_return(
          is_valid: false,
          messages: [validation_message]
        )
      end

      context 'validation note exists' do
        let(:note_attributes) do
          [
            ShopifyAPI::NoteAttribute.new(
              name: Fulfillment::ShippingAddressValidator::VALIDATION_MESSAGE_NOTE_KEY,
              value: note_message
            )
          ]
        end

        context 'message matches existing note' do
          let(:validation_message) { 'my existing validation message' }
          let(:note_message) { validation_message }

          context 'order has validation tag' do
            let(:tags) { Fulfillment::ShippingAddressValidator::VALIDATION_ERROR_TAG }

            it 'does not save order' do
              Shopify::Utils.should_not_receive(:send_assert_true).with(order, :save)
              expect(Fulfillment::ShippingAddressValidator.validate(order)).to be_false
            end
          end

          context 'order does not have validation tag' do
            let(:tags) { '' }

            it 'adds validation error tag to order and saves it' do
              order.should_receive(:tags=).with(Fulfillment::ShippingAddressValidator::VALIDATION_ERROR_TAG)
              Shopify::Utils.should_receive(:send_assert_true).with(order, :save)
              expect(Fulfillment::ShippingAddressValidator.validate(order)).to be_false
            end
          end
        end

        context 'message does not match existing note' do
          let(:validation_message) { 'my new validation message' }
          let(:note_message) { 'my existing validation message' }

          context 'order has validation tag' do
            let(:tags) { Fulfillment::ShippingAddressValidator::VALIDATION_ERROR_TAG }

            it 'saves order with new message' do
              Shopify::Utils.should_receive(:send_assert_true).with(order, :save)
              expect(Fulfillment::ShippingAddressValidator.validate(order)).to be_false
              expect(note_attributes.first.value).to eq validation_message
            end
          end

          context 'order does not have validation tag' do
            let(:tags) { '' }
            let(:updated_order) do
              ShopifyAPI::Order.new(
                id: order_id,
                tags: Fulfillment::ShippingAddressValidator::VALIDATION_ERROR_TAG
              )
            end

            it 'saves order with validation tag and new message' do
              Shopify::Utils.should_receive(:send_assert_true).with(order, :save)
              expect(Fulfillment::ShippingAddressValidator.validate(order)).to be_false
              expect(note_attributes.first.value).to eq validation_message
            end
          end
        end
      end

      context 'validation note does not exist' do
        let(:note_attributes) { [] }
        let(:tags) { '' }
        let(:validation_message) { 'my validation message' }
        let(:updated_order) do
          ShopifyAPI::Order.new(
            id: order_id,
            note_attributes: [
              {
                name: Fulfillment::ShippingAddressValidator::VALIDATION_MESSAGE_NOTE_KEY,
                value: validation_message
              }
            ],
            tags: Fulfillment::ShippingAddressValidator::VALIDATION_ERROR_TAG
          )
        end

        it 'saves order with validation tag and message' do
          Shopify::Utils.should_receive(:send_assert_true).with(updated_order, :save)
          expect(Fulfillment::ShippingAddressValidator.validate(order)).to be_false
        end
      end
    end
  end

  describe 'should_validate?' do
    let(:order) do
      ShopifyAPI::Order.new(
        id: 1,
        fulfillment_status: fulfillment_status
      )
    end
    let(:skus) { ['my_sku'] }

    context 'order has no line items for skus' do
      let(:fulfillment_status) { nil }
      before :each do
        Shopify::Utils
          .stub(:line_items_for_skus)
          .with(order, skus)
          .and_return([])
      end
      it 'returns false' do
        expect(Fulfillment::ShippingAddressValidator.should_validate?(order, skus)).to be_false
      end
    end

    context 'order has line items for skus' do
      before :each do
        Shopify::Utils
          .stub(:line_items_for_skus)
          .with(order, skus)
          .and_return([double('line_item')])
      end

      context 'fulfillment_status is not fulfilled' do
        let(:fulfillment_status) { nil }
        it 'returns true' do
          expect(Fulfillment::ShippingAddressValidator.should_validate?(order, skus)).to be_true
        end
      end

      context 'fulfillment_status is fulfilled' do
        let(:fulfillment_status) { 'fulfilled' }
        it 'returns false' do
          expect(Fulfillment::ShippingAddressValidator.should_validate?(order, skus)).to be_false
        end
      end
    end
  end
end
