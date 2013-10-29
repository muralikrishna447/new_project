class GiftCertificateMailer < ActionMailer::Base
  default from: "info@chefsteps.com"

  def recipient_email(purchaser, title, redeem_url, recipient_email, recipient_name, recipient_message)
    puts "****************** MAILER"
    @gift_title = title
    @redeem_url = redeem_url 
    @recipient_name = recipient_name 
    @recipient_message = recipient_message
    @purchaser_name = purchaser.name || purchaser.email
    mail(to: recipient_email, subject: "A gift for you from " + @purchaser_name)
  end
end
