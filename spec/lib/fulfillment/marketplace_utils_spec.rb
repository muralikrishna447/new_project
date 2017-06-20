require 'spec_helper'

describe Fulfillment::MarketplaceUtils do
  describe 'items_for_fulfillment' do
    let(:line_item) { double('line_item') }
    let(:order) { ShopifyAPI::Order.new(line_items: [line_item]) }
    let(:vendor) { 'my vendor ' }
    let(:fulfillment_details) { 'Fulfillment Option 1' }

    context 'fulfillable_line_item? returns true' do
      before :each do
        Fulfillment::MarketplaceUtils.stub(:fulfillable_line_item?) { true }
      end

      context 'fulfillment details matches line item' do
        before :each do
          Fulfillment::MarketplaceUtils.stub(:fulfillment_details).with(line_item) { fulfillment_details }
        end

        it 'returns array with line item' do
          expect(Fulfillment::MarketplaceUtils.items_for_fulfillment(order,vendor, fulfillment_details))
            .to eq [line_item]
        end
      end

      context 'fulfillment details does not match line item' do
        before :each do
          Fulfillment::MarketplaceUtils.stub(:fulfillment_details).with(line_item) { nil }
        end

        it 'returns empty array' do
          expect(Fulfillment::MarketplaceUtils.items_for_fulfillment(order,vendor, fulfillment_details))
            .to be_empty
        end
      end
    end
  end

  describe 'fulfillable_line_item?' do
    let(:order) { ShopifyAPI::Order.new(fulfillments: []) }
    let(:vendor) { 'my vendor' }
    let(:line_item) do
      ShopifyAPI::LineItem.new(
        vendor: vendor,
        fulfillable_quantity: fulfillable_quantity
      )
    end

    context 'vendor matches on line item' do
      context 'fulfillable_quantity is greater than zero' do
        let(:fulfillable_quantity) { 1 }

        context 'payment has been captured' do
          before :each do
            Fulfillment::PaymentStatusFilter.stub(:payment_captured?).with(order) { true }
          end

          it 'returns true' do
            expect(Fulfillment::MarketplaceUtils.fulfillable_line_item?(order, line_item, vendor)).to be_true
          end
        end

        context 'payment has not been captured' do
          before :each do
            Fulfillment::PaymentStatusFilter.stub(:payment_captured?).with(order) { false }
          end

          it 'returns false' do
            expect(Fulfillment::MarketplaceUtils.fulfillable_line_item?(order, line_item, vendor)).to be_false
          end
        end
      end

      context 'fulfillable_quantity is zero' do
        let(:fulfillable_quantity) { 0 }
        it 'returns false' do
          expect(Fulfillment::MarketplaceUtils.fulfillable_line_item?(order, line_item, vendor)).to be_false
        end
      end
    end

    context 'vendor does not match on line item' do
      let(:fulfillable_quantity) { 1 }
      it 'returns false' do
        expect(Fulfillment::MarketplaceUtils.fulfillable_line_item?(order, line_item, 'my other vendor')).to be_false
      end
    end
  end

  describe 'pickup_details' do
    let(:line_item) do
      ShopifyAPI::LineItem.new(
        properties: properties
      )
    end

    context 'pickup details is empty' do
      let(:properties) { [] }
      it 'returns nil' do
        expect(Fulfillment::MarketplaceUtils.pickup_details(line_item)).to be_nil
      end
    end

    context 'pickup details is non-empty' do
      let(:pickup_details) { 'my pickup details' }
      let(:property) { ShopifyAPI::LineItem::Property.new(name: 'Pickup Details', value: pickup_details) }
      let(:properties) { [property] }
      it 'returns pickup details' do
        expect(Fulfillment::MarketplaceUtils.pickup_details(line_item)).to eq pickup_details
      end
    end

    context 'multiple pickup details properties exist' do
      let(:pickup_details) { 'my pickup details' }
      let(:property) { ShopifyAPI::LineItem::Property.new(name: 'Pickup Details', value: pickup_details) }
      let(:properties) { [property, property] }

      it 'raises exception' do
        expect { Fulfillment::MarketplaceUtils.pickup_details(line_item) }.to raise_error
      end
    end
  end

  describe 'delivery_details' do
    let(:line_item) do
      ShopifyAPI::LineItem.new(
        properties: properties
      )
    end

    context 'delivery details is empty' do
      let(:properties) { [] }
      it 'returns nil' do
        expect(Fulfillment::MarketplaceUtils.delivery_details(line_item)).to be_nil
      end
    end

    context 'delivery details is non-empty' do
      let(:delivery_details) { 'my delivery details' }
      let(:property) { ShopifyAPI::LineItem::Property.new(name: 'Delivery Details', value: delivery_details) }
      let(:properties) { [property] }
      it 'returns delivery details' do
        expect(Fulfillment::MarketplaceUtils.delivery_details(line_item)).to eq delivery_details
      end
    end

    context 'multiple delivery details properties exist' do
      let(:delivery_details) { 'my delivery details' }
      let(:property) { ShopifyAPI::LineItem::Property.new(name: 'Delivery Details', value: delivery_details) }
      let(:properties) { [property, property] }

      it 'raises exception' do
        expect { Fulfillment::MarketplaceUtils.delivery_details(line_item) }.to raise_error
      end
    end
  end

  describe 'fulfillment_details' do
    let(:line_item) { double('line_item') }

    context 'line item is for delivery' do
      let(:delivery_details) { 'my delivery details' }
      before :each do
        Fulfillment::MarketplaceUtils.stub(:delivery?).with(line_item) { true }
        Fulfillment::MarketplaceUtils.stub(:delivery_details).with(line_item) { delivery_details }
      end
      it 'returns delivery details' do
        expect(Fulfillment::MarketplaceUtils.fulfillment_details(line_item)).to eq delivery_details
      end
    end

    context 'line item is for pickup' do
      let(:pickup_details) { 'my pickup details' }
      before :each do
        Fulfillment::MarketplaceUtils.stub(:delivery?).with(line_item) { false }
        Fulfillment::MarketplaceUtils.stub(:pickup_details).with(line_item) { pickup_details }
      end
      it 'returns pickup details' do
        expect(Fulfillment::MarketplaceUtils.fulfillment_details(line_item)).to eq pickup_details
      end
    end
  end

  describe 'delivery?' do
    let(:line_item) { ShopifyAPI::LineItem.new(variant_title: variant) }

    context 'line item is delivery variant' do
      let(:variant) { 'Delivery' }
      it 'returns true' do
        expect(Fulfillment::MarketplaceUtils.delivery?(line_item)).to be_true
      end
    end

    context 'line item is not delivery variant' do
      let(:variant) { 'not delivery' }
      it 'returns false' do
        expect(Fulfillment::MarketplaceUtils.delivery?(line_item)).to be_false
      end
    end
  end

  describe 'pickup?' do
    let(:line_item) { ShopifyAPI::LineItem.new(variant_title: variant) }

    context 'line item is pickup variant' do
      let(:variant) { 'Pickup' }
      it 'returns true' do
        expect(Fulfillment::MarketplaceUtils.pickup?(line_item)).to be_true
      end
    end

    context 'line item is not pickup variant' do
      let(:variant) { 'not pickup' }
      it 'returns false' do
        expect(Fulfillment::MarketplaceUtils.pickup?(line_item)).to be_false
      end
    end
  end

  describe 'sms_opted_in?' do
    let(:order) { ShopifyAPI::Order.new(note_attributes: note_attributes) }

    context 'order has sms-opted-in note attribute with value true' do
      let(:note_attributes) do
        [
          ShopifyAPI::NoteAttribute.new(name: 'sms-opted-in', value: 'true')
        ]
      end
      it 'returns true' do
        expect(Fulfillment::MarketplaceUtils.sms_opted_in?(order)).to be_true
      end
    end

    context 'order has sms-opted-in note attribute with non-true value' do
      let(:note_attributes) do
        [
          ShopifyAPI::NoteAttribute.new(name: 'sms-opted-in', value: 'false')
        ]
      end
      it 'returns false' do
        expect(Fulfillment::MarketplaceUtils.sms_opted_in?(order)).to be_false
      end
    end

    context 'order does not have sms-opted-in note attribute' do
      let(:note_attributes) { [] }
      it 'returns false' do
        expect(Fulfillment::MarketplaceUtils.sms_opted_in?(order)).to be_false
      end
    end
  end

  describe 'sms_reminders_available?' do
    let(:vendor) { 'my vendor' }

    context 'sms_reminders_available metafield exists' do
      let(:metafields) do
        [
          ShopifyAPI::Metafield.new(
            namespace: 'chefsteps',
            key: 'sms_reminders_available',
            value: metafield_value
          )
        ]
      end
      before :each do
        Fulfillment::MarketplaceUtils.stub(:vendor_metafields).with(vendor) { metafields }
      end

      context 'metafield value is true' do
        let(:metafield_value) { 'true' }
        it 'returns true' do
          expect(Fulfillment::MarketplaceUtils.sms_reminders_available?(vendor)).to be_true
        end
      end

      context 'metafield value is not true' do
        let(:metafield_value) { 'false' }
        it 'returns false' do
          expect(Fulfillment::MarketplaceUtils.sms_reminders_available?(vendor)).to be_false
        end
      end

      context 'sms_reminders_available metafield does not exist' do
        let(:metafields) { [] }
        it 'returns false' do
          expect(Fulfillment::MarketplaceUtils.sms_reminders_available?(vendor)).to be_false
        end
      end
    end
  end

  describe 'vendor_metafields' do
    let(:vendor) { 'my vendor' }

    context 'vendor collection does not exist' do
      before :each do
        ShopifyAPI::SmartCollection.stub(:find) { [] }
      end
      it 'returns empty array' do
        expect(Fulfillment::MarketplaceUtils.vendor_metafields(vendor)).to be_empty
      end
    end

    context 'more than one vendor collection exists' do
      before :each do
        ShopifyAPI::SmartCollection.stub(:find) do
          [
            ShopifyAPI::SmartCollection.new,
            ShopifyAPI::SmartCollection.new
          ]
        end
      end
      it 'returns empty array' do
        expect(Fulfillment::MarketplaceUtils.vendor_metafields(vendor)).to be_empty
      end
    end

    context 'one vendor collection exists' do
      let(:metafields) do
        [
          ShopifyAPI::Metafield.new(
            namespace: 'foo',
            key: 'bar',
            value: 'baz'
          )
        ]
      end
      let(:collection) do
        collection = double('collection')
        collection.should_receive(:metafields).and_return(metafields)
        collection
      end
      before :each do
        ShopifyAPI::SmartCollection.stub(:find) { [collection] }
      end

      it 'returns collection metafields' do
        expect(Fulfillment::MarketplaceUtils.vendor_metafields(vendor)).to eq metafields
      end
    end
  end
end
