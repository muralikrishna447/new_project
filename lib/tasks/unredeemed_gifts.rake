task :email_unredeemed_gifts => :environment do
  # gifts = GiftCertificate.where(redeemed: false)
  gifts = GiftCertificate.where(recipient_email: 'hueezer@hotmail.com').take(3)

  gifts.each do |gift|
    puts '***************************'
    puts "Sending email for gift:"
    puts gift.inspect
    gift.resend_email(gift.recipient_email)
    puts '***************************'
  end
end