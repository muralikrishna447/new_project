class GiftCertificateMailer < ActionMailer::Base
  default from: "info@chefsteps.com"

  def recipient_email(to_recipient, purchaser, title, redeem_url, recipient_email, recipient_name, recipient_message)
    set_variables(to_recipient, purchaser, title, redeem_url, recipient_email, recipient_name, recipient_message)
    if @to_recipient
      mail(to: @recipient_email, subject: @recipient_subject)
    else
      mail(to: @purchaser.email, subject: "ChefSteps.com - gift purchase for " + @recipient_name)
    end
  end

  def resend_recipient_email(to_recipient, purchaser, title, redeem_url, recipient_email, recipient_name, recipient_message)
    set_variables(to_recipient, purchaser, title, redeem_url, recipient_email, recipient_name, recipient_message)
    if @to_recipient
      mail(to: @recipient_email, subject: @recipient_subject)
    else
      mail(to: @purchaser.email, subject: "ChefSteps.com - gift purchase for " + @recipient_name)
    end
  end

private
  def set_variables(to_recipient, purchaser, title, redeem_url, recipient_email, recipient_name, recipient_message)
    # puts "****************** MAILER"
    # puts to_recipient
    @to_recipient = to_recipient
    @recipient_email = recipient_email
    @purchaser = purchaser
    @gift_title = title
    @redeem_url = redeem_url
    @recipient_name = recipient_name
    @recipient_message = recipient_message

    @recipient_subject = @purchaser.name + ' gifted you the ' + @gift_title + ' Class on ChefSteps.'
  end
end
