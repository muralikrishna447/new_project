class GenericReceiptMailer < BaseMandrillMailer
  def prepare(user, merge_vars)
    subject = "ChefSteps Receipt"
    body = mandrill_template("generic-receipt", merge_vars)
    send_mail(user.email, subject, body)
  end
end