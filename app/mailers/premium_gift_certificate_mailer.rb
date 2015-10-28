class PremiumGiftCertificateMailer < ActionMailer::Base
  default from: "info@chefsteps.com"

  def recipient_email(purchaser, redeem_url)
    set_variables(purchaser, redeem_url)
    mail(to: @purchaser.email, subject: "ChefSteps.com - ChefSteps Premium gift purchase")
  end

private
  def set_variables(purchaser, redeem_url)
    @purchaser = purchaser
    @redeem_url = redeem_url
  end
end
