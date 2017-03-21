require "spec_helper"

describe RostiOrderSubmitterMailer do
  # before(:each) do
  #   ActionMailer::Base.delivery_method = :test
  #   ActionMailer::Base.perform_deliveries = false
  #   ActionMailer::Base.deliveries = []
  # end
  #
  # after(:each) do
  #   ActionMailer::Base.deliveries.clear
  # end

  describe "notification" do
    let(:email_address){ 'test@example.com' }
    let(:info){
      {
          email_address: email_address,
          total_quantity: 108
      }

    }
    it "should send an email" do
      mail = RostiOrderSubmitterMailer.notification(info)

      puts mail

      mail.deliver

      ActionMailer::Base.deliveries.count.should == 1
      email = ActionMailer::Base.deliveries.first

      expect(email[:subject].to_s).to match(/^ChefSteps Fulfillment File Notification \d\d\/\d\d\/\d\d\d\d - 108 units$/)
      expect(email[:to].to_s).to eq email_address
    end
  end
end