require 'spec_helper'

describe Shipwire, focus: true do
  let(:username) { 'test_shipwire_username' }
  let(:password) { 'test_shipwire_password' }
  let(:url) { 'https://testshipwire/api/v3' }

  describe 'unique_order_by_number' do
    context 'order does not exist' do
      it 'returns nil' do
      end
    end

    context 'one order exists with matching number' do
      before do
        stub_request(:get, /url/).with(headers: {
          'Accept' => 'application/json'
        }).to_return(status: 200, body: File.read(Rails.root.join('spec', 'api_responses', 'shipwire_orders_response.json')))
      end

      it 'returns the order' do
        order = Shipwire.unique_order_by_number('#1288.1')
      end
    end

    context 'multiple orders exist with matching numbers' do
      it 'raises exception' do
      end
    end

    context 'http status code is not 200' do
      it 'raises exception' do
      end
    end
  end
end
