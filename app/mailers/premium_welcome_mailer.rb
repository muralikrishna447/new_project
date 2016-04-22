class PremiumWelcomeMailer < ActionMailer::Base

  default from: "info@chefsteps.com"

  def prepare(user, bonus = false)
    logger.info("Preparing premium welcome mail for user [#{user.email}] with is_joule [#{bonus}]")
    subject = bonus ? "While You Wait for Joule, Check Out Your New Premium Account" : "Welcome To ChefSteps Premium"

    substitutions = {
      sub: {
        "*|SUBJECT|*" => [subject],
        "*|EMAIL|*" => [user.email],
        "*|CURRENT_YEAR|*" => [Time.now.year]
      }
    }
    headers['X-SMTPAPI'] = substitutions.to_json
    mail(to: user.email, subject: subject)
  end
end
