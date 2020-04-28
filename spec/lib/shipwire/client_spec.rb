require 'spec_helper'

describe Shipwire::Client do
  let(:username) { 'test_shipwire_username' }
  let(:password) { 'test_shipwire_password' }
  let(:base_uri) { 'testshipwire/api/v3' }
  let(:order_number) { '#1288.1' }
  let(:request_uri) do
    "https://#{base_uri}/orders?expand=trackings,holds&limit=2&offset=0&orderNo=#{URI.encode(order_number)}"
  end

  before do
    Shipwire::Client.configure(
      username: username,
      password: password,
      base_uri: "https://#{base_uri}"
    )
  end

  describe 'unique_order_by_number' do
    context 'order does not exist' do
      it 'returns nil' do
      end
    end

    context 'one order exists with matching number' do
      before do
        stub_orders_request(200, 'shipwire_orders_response_single.json')
      end

      it 'returns the order' do
        order = Shipwire::Client.unique_order_by_number(order_number)
        expect(order).to eq Shipwire::Order.new(
          id: 198794572,
          number: '#1292.1',
          status: 'delivered',
          trackings: [],
          holds: []
        )
      end
    end

    context 'multiple orders exist with matching numbers' do
      before do
        stub_orders_request(200, 'shipwire_orders_response_duplicate.json')
      end

      it 'raises exception' do
        expect { Shipwire::Client.unique_order_by_number(order_number) }.to raise_error
      end
    end

    context 'http status code is not 200' do
      before do
        stub_orders_request(404)
      end

      it 'raises exception' do
        expect { Shipwire::Client.unique_order_by_number(order_number) }.to raise_error
      end
    end
  end

  def stub_orders_request(status, body_file_name = nil)
    if body_file_name
      body = File.read(Rails.root.join('spec', 'api_responses', body_file_name))
    else
      body = ''
    end

    WebMock
        .stub_request(:get, request_uri)
        .with(
            basic_auth: [username, password],
            headers: {
                'Accept' => 'application/json',
                'Content-Type' => 'application/json'
            }
        )
        .to_return(status: status, body: body)
  end
end
