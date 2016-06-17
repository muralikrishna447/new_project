class IdempotentMailInterceptor
  DELIVERED = 'delivered'
  SENDING = 'sending'
  @@client = Aws::DynamoDB::Client.new(region: 'us-east-1')
  def self.delivering_email(message)
    ensure_single_address(message)
    if message.header['X-IDEMPOTENCY']
      message_token =  message.header['X-IDEMPOTENCY'].to_s
    end
    if message_token.nil?
      # Generate a suitable key for logging purposes only
      message_token = "#{Time.now.utc.iso8601} #{message.subject}"
      message.header['X-IDEMPOTENCY'] = message_token
    end
    email = message.to.first

    Rails.logger.info "Persisting log entry for [#{email}] and [#{message_token}]"
    unless check_and_put_log(email, message_token)
      Rails.logger.info "Delivered entry already exists for user [#{email}] and message token [#{message_token}] not delivering"
      message.perform_deliveries = false 
    end
  end
  
  def self.delivered_email(message)
    ensure_single_address(message)
    message_token = message.header['X-IDEMPOTENCY'].to_s
    email = message.to.first
    unless message.perform_deliveries == false
      log_update(email, message_token)
    else
      Rails.logger.info "Skipping update for [#{email}] and [#{message_token}] as perform_deliveries is false"
    end
  end
  
  private
  def self.check_and_put_log(email, message_token)
    begin
      @@client.put_item(
      {
        table_name: Rails.configuration.dynamodb.transactional_email_log_table_name,
        item: {
          'email' => email,
          'messageToken' => message_token,
          'messageStatus' => SENDING
        },
        condition_expression: "attribute_not_exists(email) and attribute_not_exists(messageToken)"
      })
    rescue Aws::DynamoDB::Errors::ConditionalCheckFailedException => e
      # Determine if insert failed because email is stuck or already delivered
      resp = @@client.get_item(
        table_name: Rails.configuration.dynamodb.transactional_email_log_table_name,
        key: {
          'email' => email,
          'messageToken' => message_token
        }
      )
      messageStatus = resp ? resp.item['messageStatus'] : nil
      if messageStatus == DELIVERED
        Rails.logger.info "Found delivered entry for [#{email}] [#{message_token}]"
        return false
      else
        raise Exception.new("Entry for [#{email}] and [#{message_token}] is already in [#{messageStatus}] state")
      end
    end
    return true
  end
  
  def self.log_update(email, message_token)
    @@client.update_item({
      table_name: Rails.configuration.dynamodb.transactional_email_log_table_name,
      key: {
        'email' => email,
        'messageToken' => message_token,
      },
      condition_expression: "attribute_exists(email) and attribute_exists(messageToken) and messageStatus = :sending ",
      update_expression: 'SET messageStatus = :delivered',
      expression_attribute_values: {":delivered" => DELIVERED, ":sending" => SENDING}
    })
  end

  def self.ensure_single_address(message)
    if message.to.length > 1
      raise Exception.new("Idempotent mail sender does not support multiple to addresses [#{message.to.inspect}]")
    end
  end
end
