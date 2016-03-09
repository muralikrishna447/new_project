class PremiumWelcomeMailer < BaseMandrillMailer
  def prepare(user, bonus = false)
    logger.info("Preparing premium welcome mail for user [#{user.email}] with is_joule [#{bonus}]")
    subject = bonus ? "While You Wait for Joule, Check Out Your New Premium Account" : "Welcome To ChefSteps Premium"
    merge_vars = {}
    body = mandrill_template("premium-purchase-confirmation", merge_vars)
    send_mail(user.email, subject, body)
  end
end
