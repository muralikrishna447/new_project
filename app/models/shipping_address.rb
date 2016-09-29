class ShippingAddress < MailingAddress

  @@client = Aws::DynamoDB::Client.new(region: 'us-east-1')

  def save_record(order_id,user_id)
    begin
      if !Rails.env.test?
        order = ShopifyAPI::Order.find(order_id)
        order.shipping_address.address1 = address1
        order.shipping_address.address2 = address2
        order.shipping_address.city = city
        order.shipping_address.province_code = province
        order.shipping_address.zip = zip
        order.save
      end
    rescue => e
      Rails.logger.error "ShippingAddress update error: #{e} while trying to save item: #{item}"
      raise Exception.new("Error saving ShippingAddress")
    end
  end

  def self.confirm(order_id)
    item = {
      'orderId' => order_id,
      'createdAt' => DateTime.now.to_i
    }
    begin
      if !Rails.env.test?
        @@client.put_item(
        {
          table_name: Rails.configuration.dynamodb.shipping_address_confirmation_table_name,
          item: item
        })
      end
    rescue => e
      Rails.logger.error "ShippingAddress confirmation error: #{e} while trying to save item: #{item}"
      raise Exception.new("Error confirming ShippingAddress")
    end
  end

end
