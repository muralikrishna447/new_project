task :email_unredeemed_gifts => :environment do
  gifts = GiftCertificate.unredeemed.one_week_old

  gifts.each do |gift|
    puts '***************************'
    puts "Sending email for gift:"
    puts gift.inspect
    # gift.resend_email(gift.recipient_email)
    puts '***************************'
  end
end