# We ran an A/B test and sold a class for 9 and 14 dollars, this will refund them and let them know
task :refund_coupon_price => :environment do
  Intercom.app_id = "vy04t2n1"
  Intercom.app_api_key = "149f294a76e91fecb7b66c6bed1889e64f487d07"

  Rails.logger.level = Logger::DEBUG
  charges = Stripe::Charge.all(created: {gte: (Time.now-1.day).beginning_of_day.to_i, lte: (Time.now-1.day).end_of_day.to_i}, refunded: false, amount: 1400, paid: true, limit: 1000)
  charges.each do |charge|
    next unless charge.refunds.blank?
    Stripe::Charge.retrieve(charge.id)
    charge.refund(amount: 500)
    Intercom::Message.create({
      :message_type => 'email',
      :subject  => 'Black Friday sale price reduction for Sous Vide: Beyond the Basics',
      :body     => "Just a quick note to let you know that we are refunding you $5 for the purchase of the SV 201 course that you recently made. We've decided to offer it at a cost of $9 during our Black Friday special and want to refund you the difference from what you paid for the class.\n\nYou should see the refund on your credit card statement within the next week or so.\n\nHappy Holidays from ChefSteps!",
      :template => "plain", # or "personal",
      :from => {
        :type => "admin",
        :id   => 42829
      },
      :to => {
        :type => "user",
        :email => charge.receipt_email
      }
    })
  end


end