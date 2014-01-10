require "spec_helper"

describe UserMailer do
  let(:sender) { Fabricate(:user, name: "Test User")}
  let(:to) { ["dan@chefsteps.com", "danahern@chefsteps.com", "dahern@chefsteps.com"] }
  describe ".invitations" do
    context "should " do
      it "should create an email to the recipient_email" do
        UserMailer.invitations(to, sender).deliver
        check_email(bcc: ["dan@chefsteps.com", "danahern@chefsteps.com", "dahern@chefsteps.com"] }, subject: "Join Test User on ChefSteps and cook smarter", from: "info@chefsteps.com")
      end
    end
  end
end
