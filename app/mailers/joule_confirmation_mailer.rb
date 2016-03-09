class JouleConfirmationMailer < BaseMandrillMailer
  def prepare(user)
    logger.info("Preparing joule confirmation mail for user [#{user.email}]")
    subject = "Thank You For Purchasing Joule!"
    merge_vars = {}
    body = mandrill_template("joule-purchase-confirmation", merge_vars)
    send_mail(user.email, subject, body)
  end
end
