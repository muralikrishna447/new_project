require 'spec_helper'

describe Shipwire::Tracking do
  describe 'array_from_hash' do
    context 'hash contains tracking items' do
      let(:number_1) { 'tracking number 1' }
      let(:carrier_1) { 'carrier 1' }
      let(:url_1) { 'url 1' }
      let(:number_2) { 'tracking number 2' }
      let(:carrier_2) { 'carrier 2' }
      let(:url_2) { 'url 2' }

      it 'returns array of trackings' do
        array = Shipwire::Tracking.array_from_hash(
          'resource' => {
            'items' => [
              {
                'resource' => {
                  'tracking' => number_1,
                  'carrier' => carrier_1,
                  'url' => url_1
                }
              },
              {
                'resource' => {
                  'tracking' => number_2,
                  'carrier' => carrier_2,
                  'url' => url_2
                }
              }
            ]
          }
        )
        expect(array).to eq(
          [
            Shipwire::Tracking.new(
              number: number_1,
              carrier: carrier_1,
              url: url_1
            ),
            Shipwire::Tracking.new(
              number: number_2,
              carrier: carrier_2,
              url: url_2
            )
          ]
        )
      end
    end

    context 'hash contains invalid structure' do
      it 'raises exception' do
        expect { Shipwire::Tracking.array_from_hash({}) }.to raise_error
      end
    end
  end
end
