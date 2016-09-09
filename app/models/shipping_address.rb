class ShippingAddress < MailingAddress

  @@client = Aws::DynamoDB::Client.new(region: 'us-east-1')

  def save_record(order_id,user_id)
    item = {
      'orderId' => order_id,
      'userId' => user_id,
      'address1' => address1,
      'address2' => address2,
      'city' => city,
      'province' => province,
      'zip' => zip,
      'createdAt' => DateTime.now.to_i
    }
    begin
      if !Rails.env.test?
        @@client.put_item(
        {
          table_name: Rails.configuration.dynamodb.shipping_address_table_name,
          item: item
        })
      end
    rescue => e
      raise Exception.new("Error saving ShippingAddress")
      Rails.logger.info "ShippingAddress Error: #{e} while trying to save item: #{item}"
    end
  end

end
