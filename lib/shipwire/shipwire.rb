module Shipwire
  class << self
    def self.configure(options)
      raise 'Shipwire username is required' unless options[:username]
      raise 'Shipwire password is required' unless options[:password]
      raise 'Shipwire base URI is required' unless options[:base_uri]
      @auth = {
        username: options[:username],
        password: options[:password]
      }
      @url = options[:base_uri]
    end

    def self.unique_order_by_number(order_number)
      orders = orders_page(order_number, 0, 2)
      if orders.size > 1
        raise "Expected one order with number #{order_number}, found #{orders.size}"
      elsif orders.size == 1
        orders.first
      end
    end

    private

    def orders_page(order_number, offset, limit)
      url = "#{@base_uri}/orders?orderNo=#{order_number}&offset=#{offset}&limit=#{limit}"
      response = HTTParty.get(url, basic_auth: @auth, headers: {
        'Accept' => 'application/json'
      })
      if response.code != 200
        raise "Request to Shipwire at URL #{url} failed with response code #{response.code} and body #{response.body}"
      end
      Shipwire::Order.array_from_json(response.body)
    end
  end
end
