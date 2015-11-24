class JouleConfirmationMailer < BaseMandrillMailer
  def prepare(user)
    subject = "Thank You For Purchasing Joule!"
    merge_vars = {}
    body = mandrill_template("joule-purchase-confirmation", merge_vars)
    send_mail(user.email, subject, body)
  end
end