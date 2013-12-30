module MailerMacros
  def check_email(attribute_hash)
    ActionMailer::Base.deliveries.count.should == 1
    email = ActionMailer::Base.deliveries.first
    attribute_hash.each_pair do |key, value|
      Array.wrap(email.send(key)).should eq Array.wrap(value)
    end
  end
end
