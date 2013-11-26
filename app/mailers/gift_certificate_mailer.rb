class GiftCertificateMailer < ActionMailer::Base
  default from: "info@chefsteps.com"

  def recipient_email(to_recipient, purchaser, title, redeem_url, recipient_email, recipient_name, recipient_message)
    puts "****************** MAILER"
    puts to_recipient
    @gift_title = title
    @redeem_url = redeem_url 
    @recipient_name = recipient_name 
    @recipient_message = recipient_message
    @purchaser_name = purchaser.email
    @purchaser_name = "#{purchaser.name} (#{purchaser.email})" if purchaser.name
    if to_recipient
      mail(to: recipient_email, subject: "A gift for you from " + @purchaser_name)
    else
      mail(to: purchaser.email, subject: "ChefSteps.com - gift purchase for " + @recipient_name)
    end
  end
end
