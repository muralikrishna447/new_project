module Shipwire
  class Client
    def self.configure(options)
      raise 'Shipwire username is required' unless options[:username]
      raise 'Shipwire password is required' unless options[:password]
      raise 'Shipwire base URI is required' unless options[:base_uri]
      @auth = {
        username: options[:username],
        password: options[:password]
      }
      @base_uri = options[:base_uri]
    end

    def self.unique_order_by_number(order_number)
      orders = orders_page(order_number, 0, 2)
      if orders.size > 1
        raise "Expected one order with number #{order_number}, found #{orders.size}"
      elsif orders.size == 1
        orders.first
      end
    end

    private_class_method
    def self.orders_page(order_number, offset, limit)
      url = "#{@base_uri}/orders?orderNo=#{URI.encode(order_number)}&expand=trackings&offset=#{offset}&limit=#{limit}"
      response = HTTParty.get(
        url,
        basic_auth: @auth,
        headers: {
          'Accept' => 'application/json',
          'Content-Type' => 'application/json'
        }
      )
      if response.code != 200
        raise "Request to Shipwire at URL #{url} failed with response code #{response.code} and body #{response.body}"
      end
      Shipwire::Order.array_from_json(response.body)
    end
  end
end
