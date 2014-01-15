task :email_unredeemed_gifts => :environment do
  gifts = GiftCertificate.where(redeemed: false)

  gifts.each do |gift|
    puts '***************************'
    puts gift.inspect
    puts '***************************'
  end
end