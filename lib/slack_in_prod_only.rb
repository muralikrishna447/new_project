module SlackInProdOnly
  class << self
    def send(channel, message, username = "Website Ghost")
      if Rails.env == "production" && ENV["SLACK_WEBHOOK"]
        slack = Slack::Notifier.new ENV["SLACK_WEBHOOK"], channel: channel, username: username
        slack.ping message
      end
    end
  end
end