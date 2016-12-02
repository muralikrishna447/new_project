class RandomDrop

  @@client = Aws::DynamoDB::Client.new(region: 'us-west-2')

  def self.get(user_id)
    begin
      if !Rails.env.test?
        response = @@client.query(
          table_name: Rails.configuration.dynamodb.random_drop_table_name,
          select: "ALL_ATTRIBUTES",
          key_condition_expression: 'user_id = :user_id',
          expression_attribute_values: {
            ':user_id' => user_id.to_s
          }
        )
        puts "RESPONSE: #{response.inspect}"
        items = response.items
          .map {|item| Hash[item.each_pair.to_a]}
          .map {|item|
            created_at = item['created_at']
            item['created_at_int'] = Time.parse(created_at).to_i
            item
          }
          .sort {|item| item['created_at_int']}

        return items.last
      end
    rescue => e
      Rails.logger.error "Error: #{e} while trying to get random drop for user id: #{user_id}"
      raise Exception.new("RandomDrop Error get()")
    end
  end

end
