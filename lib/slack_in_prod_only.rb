module SlackInProdOnly
  class << self
    def send(channel, message, username = "Website Ghost")
      if Rails.env == "production" && ENV["SLACK_WEBHOOK"]
        begin
          slack = Slack::Notifier.new ENV["SLACK_WEBHOOK"], channel: channel, username: username
          slack.ping message
        rescue => e
          # Never let any kind of slack failure keep us from our appointed rounds
          Rails.logger.error "SlackInProdOnly failed with error: #{e}, send message \'#{message}\'"
        end
      else
        Rails.logger.info "SlackInProdOnly would have sent channel: #{channel}, user: #{username}, message: \'#{message}\'"
      end
    end
  end
end