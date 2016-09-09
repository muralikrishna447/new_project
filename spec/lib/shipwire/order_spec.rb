require 'spec_helper'

describe Shipwire::Order do
  describe 'array_from_json' do
    let(:orders_json) { File.read(Rails.root.join('spec', 'api_responses', 'shipwire_orders_response_multiple.json')) }

    it 'returns order array' do
      array = Shipwire::Order.array_from_json(orders_json)
      expect(array).to eq(
        [
          Shipwire::Order.new(
            id: 198651672,
            status: 'delivered',
            trackings: [
              Shipwire::Tracking.new(
                number: '9400110200793110752954',
                carrier: 'USPS',
                url: 'https://tools.usps.com/go/TrackConfirmAction.action?tLabels=9400110200793110752954'
              )
            ]
          ),
          Shipwire::Order.new(
            id: 198794572,
            status: 'delivered',
            trackings: [
              Shipwire::Tracking.new(
                number: '9400110200793110752978',
                carrier: 'USPS',
                url: 'https://tools.usps.com/go/TrackConfirmAction.action?tLabels=9400110200793110752978'
              )
            ]
          )
        ]
      )
    end
  end
end
