class PremiumWelcomeMailer < ActionMailer::Base

  default from: "info@chefsteps.com"
  layout 'mailer'

  def prepare(user, bonus = false)
    logger.info("Preparing premium welcome mail for user [#{user.email}] with is_joule [#{bonus}]")
    subject = bonus ? "While You Wait for Joule, Check Out Your New Premium Account" : "Welcome To ChefSteps Premium"
    @email = user.email

    mail(to: user.email, subject: subject)
  end
end
