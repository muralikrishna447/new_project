class JouleConfirmationMailer < ActionMailer::Base

  default from: "info@chefsteps.com"

  def prepare(user)
    logger.info("Preparing joule confirmation mail for user [#{user.email}]")
    subject = "Thank You For Purchasing Joule!"
    substitutions = {
      sub: {
        "*|SUBJECT|*" => [subject],
        "*|NAME|*" => [user.name],
        "*|CURRENT_YEAR|*" => [Time.now.year]
      }
    }
    headers['X-SMTPAPI'] = substitutions.to_json
    mail(to: user.email, subject: subject)
  end
end
