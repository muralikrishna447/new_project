task :email_unredeemed_gifts => :environment do
  gifts = GiftCertificate.recipients_to_email.unredeemed.one_week_old.not_followed_up

  gifts.each do |gift|
    next if gift.recipient_email.empty?
    puts '***************************'
    puts "Sending email for gift:"
    puts gift.inspect
    gift.resend_email(gift.recipient_email)
    puts '***************************'
  end
end

task :test_email_unredeemed_gifts => :environment do
  gifts = GiftCertificate.recipients_to_email.unredeemed.one_week_old.not_followed_up.take(5)

  gifts.each do |gift|
    next if gift.recipient_email.empty?
    puts '***************************'
    puts "Sending email for gift:"
    puts gift.inspect
    # gift.resend_email(gift.recipient_email)
    puts '***************************'
  end
end