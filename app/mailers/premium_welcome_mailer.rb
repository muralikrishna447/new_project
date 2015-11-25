class PremiumWelcomeMailer < BaseMandrillMailer
  def prepare(user, bonus = false)
    subject = bonus ? "While You Wait for Joule, Enjoy ChefSteps Premium!" : "Welcome To ChefSteps Premium"
    merge_vars = {}
    body = mandrill_template("premium-purchase-confirmation", merge_vars)
    send_mail(user.email, subject, body)
  end
end