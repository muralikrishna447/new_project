require "spec_helper"

describe GiftCertificateMailer do
  let(:purchaser){ Fabricate(:user, name: "Purchaser", email: "test@chefsteps.com") }


  describe ".recipient_email" do
    context "to_recipient true" do
      it "should create an email to the recipient_email" do
        GiftCertificateMailer.recipient_email(true, purchaser, "Become a Badass", "chefsteps.test/gift/123456", "test@example.com", "Test User", "Enjoy the gift").deliver
        check_email(to: "dev@chefsteps.com", subject: "[\"test@example.com\"] A gift for you from Purchaser (test@chefsteps.com)", from: "info@chefsteps.com")
      end
    end

    context "to_recipient false" do
      it "should create an email to the purchaser" do
        GiftCertificateMailer.recipient_email(false, purchaser, "Become a Badass", "chefsteps.test/gift/123456", "test@example.com", "Test User", "Enjoy the gift").deliver
        check_email(to: "dev@chefsteps.com", subject: "[\"test@chefsteps.com\"] ChefSteps.com - gift purchase for Test User", from: "info@chefsteps.com")
      end
    end
  end
end
