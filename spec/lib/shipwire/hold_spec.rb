require 'spec_helper'

describe Shipwire::Hold do
  describe 'array_from_hash' do
    context 'hash contains holds' do
      let(:id_1) { 1 }
      let(:id_2) { 2 }
      let(:type_1) { 'type1' }
      let(:type_2) { 'type2' }
      let(:sub_type_1) { 'subtype1' }
      let(:sub_type_2) { 'subtype2' }
      let(:cleared_date_1) { 'cleared_date1' }
      let(:cleared_date_2) { 'cleared_date2' }

      it 'returns array of holds' do
        array = Shipwire::Hold.array_from_hash(
          'resource' => {
            'items' => [
              {
                'resource' => {
                  'id' => id_1,
                  'type' => type_1,
                  'subType' => sub_type_1,
                  'clearedDate' => cleared_date_1
                }
              },
              {
                'resource' => {
                  'id' => id_2,
                  'type' => type_2,
                  'subType' => sub_type_2,
                  'clearedDate' => cleared_date_2
                }
              }
            ]
          }
        )
        expect(array).to eq(
          [
            Shipwire::Hold.new(
              id: id_1,
              type: type_1,
              sub_type: sub_type_1,
              cleared_date: cleared_date_1
            ),
            Shipwire::Hold.new(
              id: id_2,
              type: type_2,
              sub_type: sub_type_2,
              cleared_date: cleared_date_2
            )
          ]
        )
      end
    end
  end
end
