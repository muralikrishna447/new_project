class JouleConfirmationMailer < BaseMandrillMailer
  def prepare(user)
    subject = "Joule is Headed Your Way!"
    merge_vars = {}
    body = mandrill_template("joule-purchase-confirmation", merge_vars)
    send_mail(user.email, subject, body)
  end
end