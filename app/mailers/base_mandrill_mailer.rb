require "mandrill"

# From https://robots.thoughtbot.com/how-to-send-transactional-emails-from-rails-with-mandrill


class BaseMandrillMailer < ActionMailer::Base
  default(
    from: "info@chefsteps.com",
    reply_to: "info@chefsteps.com"
  )

  private

  def send_mail(email, subject, body)
    mail(to: email, subject: subject, body: body, content_type: "text/html")
  end

  def mandrill_template(template_name, attributes)
    mandrill = Mandrill::API.new(ENV['MANDRILL_APIKEY'])

    merge_vars = attributes.map do |key, value|
      { name: key, content: value }
    end

    mandrill.templates.render(template_name, [], merge_vars)["html"]
  end
  
end
