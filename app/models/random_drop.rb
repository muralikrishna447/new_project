class RandomDrop

  @@client = Aws::DynamoDB::Client.new(region: 'us-west-2')

  def self.get(user_id)
    begin
      if !Rails.env.test?

        itemStruct = @@client.get_item(
          {
            table_name: Rails.configuration.dynamodb.random_drop_table_name,
            key: {
              'user_id' => user_id.to_s
            }
          })

        @item = Hash[itemStruct.each_pair.to_a]
      end
    rescue => e
      Rails.logger.error "Error: #{e} while trying to get random drop for user id: #{user_id}"
      raise Exception.new("RandomDrop Error get()")
    end
  end

end
