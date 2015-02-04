class ReportMailer < ActionMailer::Base
  default from: "info@chefsteps.com"

  def send_report_file(to_recipient, subject, recipient_message, filename, file)
    attachments[filename] = file
    mail(to: to_recipient, subject: subject, body: recipient_message)
    puts "Sending Mail"
  end
end
