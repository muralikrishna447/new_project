class RostiOrderSubmitterMailer < ActionMailer::Base
  def notification(info)
    logger.info("RostiOrderSubmitterMailer  [#{info.to_s}]")

    [:email_address, :total_quantity].each do | key |
      raise(ArgumentError, "#{key} is required") unless info.has_key? key
    end

    @email_address = info[:email_address]
    @dropped_on = Time.now.in_time_zone('Asia/Shanghai').strftime("%m/%d/%Y")
    @total_quantity = info[:total_quantity]
    @subject = "ChefSteps Fulfillment File Notification #{@dropped_on} - #{@total_quantity} units"

    mail(to: @email_address, from: 'noreply@chefsteps.com', reply_to: @email_address, subject: @subject)
  end
end
