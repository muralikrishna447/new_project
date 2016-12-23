require 'spec_helper'

describe Fulfillment::ShippingAddressValidator do
  describe 'perform' do
    let(:order) { double('order') }
    it 'calls validate on order and reports metrics' do
      Shopify::Utils.should_receive(:search_orders).with(status: 'open').and_return([order])
      Fulfillment::ShippingAddressValidator.should_receive(:validate).with(order).and_return(true)
      Librato.should_receive(:increment).with('fulfillment.address-validator.success', sporadic: true)
      Librato.should_receive(:measure).with('fulfillment.address-validator.valid.count', 1)
      Librato.should_receive(:measure).with('fulfillment.address-validator.invalid.count', 0)
      Fulfillment::ShippingAddressValidator.perform
    end
  end

  describe 'validate' do
    let(:order) do
      order = double('order')
      order.stub(:id).and_return(1)
      order.stub(:note_attributes).and_return(note_attributes)
      order.stub(:tags).and_return(tags)
      order
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

        it 'removes tag and note and saves order' do
          order.should_receive(:tags=).with('')
          order.should_receive(:save)
          expect(Fulfillment::ShippingAddressValidator.validate(order)).to be_true
          expect(note_attributes).to eq([existing_note])
        end
      end

      context 'order has no validation tag nor note attribute' do
        let(:note_attributes) { [] }
        let(:tags) { '' }

        it 'does not save order' do
          order.should_not_receive(:save)
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
              order.should_not_receive(:save)
              expect(Fulfillment::ShippingAddressValidator.validate(order)).to be_false
            end
          end

          context 'order does not have validation tag' do
            let(:tags) { '' }

            it 'adds validation error tag to order and saves it' do
              order.should_receive(:tags=).with(Fulfillment::ShippingAddressValidator::VALIDATION_ERROR_TAG)
              order.should_receive(:save)
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
              order.should_receive(:save)
              expect(Fulfillment::ShippingAddressValidator.validate(order)).to be_false
              expect(note_attributes.first.value).to eq validation_message
            end
          end

          context 'order does not have validation tag' do
            let(:tags) { '' }

            it 'saves order with validation tag and new message' do
              order.should_receive(:tags=).with(Fulfillment::ShippingAddressValidator::VALIDATION_ERROR_TAG)
              order.should_receive(:save)
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

        it 'saves order with validation tag and message' do
          order.should_receive(:tags=).with(Fulfillment::ShippingAddressValidator::VALIDATION_ERROR_TAG)
          order.should_receive(:save)
          expect(Fulfillment::ShippingAddressValidator.validate(order)).to be_false
          expect(note_attributes).to eq [
            {
              name: Fulfillment::ShippingAddressValidator::VALIDATION_MESSAGE_NOTE_KEY,
              value: validation_message
            }
          ]
        end
      end
    end
  end
end
