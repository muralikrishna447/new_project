require "spec_helper"

describe GiftCertificateMailer do
  let(:purchaser){ Fabricate(:user, name: "Purchaser", email: "test@chefsteps.com") }


  describe ".recipient_email" do
    context "to_recipient true" do
      it "should create an email to the recipient_email" do
        GiftCertificateMailer.recipient_email(true, purchaser, "Become a Badass", "chefsteps.test/gift/123456", "test@example.com", "Test User", "Enjoy the gift").deliver
        check_email(to: "test@example.com", subject: "Purchaser gifted you the Become a Badass Class on ChefSteps.", from: "info@chefsteps.com")
      end
    end

    context "to_recipient false" do
      it "should create an email to the purchaser" do
        GiftCertificateMailer.recipient_email(false, purchaser, "Become a Badass", "chefsteps.test/gift/123456", "test@example.com", "Test User", "Enjoy the gift").deliver
        check_email(to: "test@chefsteps.com", subject: "ChefSteps.com - gift purchase for Test User", from: "info@chefsteps.com")
      end
    end
  end
end
