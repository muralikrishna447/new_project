
class PremiumGiftCertificateMailer < BaseMandrillMailer
  def prepare(user, redeem_token)
    subject = "ChefSteps Premium Gift Certificate"
    merge_vars = {"REDEEM_TOKEN" => redeem_token}
    body = mandrill_template("premium-gift-certificate", merge_vars)
    send_mail(user.email, subject, body)
  end
end