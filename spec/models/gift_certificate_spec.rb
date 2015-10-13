require 'spec_helper'

describe GiftCertificate, pending: true do
  let(:purchaser){ Fabricate(:user, name: "Purchaser", email: "test@chefsteps.com") }
  let(:ip_address) { "10.0.0.1" }
  let(:assembly) { Fabricate(:assembly, price: 39.00, assembly_type: "Course") }
  let(:discounted_price) { 19.99 }
  let(:stripe_token) { "12345" }
  let(:gift_info) { {"recipientEmail" => "dan@chefsteps.com", "recipientName" => "Dan", "recipientMessage" => "Testing", "emailToRecipient" => "nad@chefsteps.com"} }
  let(:gift_certificate){ Fabricate(:gift_certificate, assembly_id: assembly.id, redeemed: false, purchaser_id: purchaser.id, recipient_email: "danahern@chefsteps.com", recipient_name: "Dan Ahern Recipient", recipient_message: "Enjoy") }

  before(:each) do
    SecureRandom.stub(:urlsafe_base64).and_return("123456", "234567")
  end

  after(:each) do
    ActionMailer::Base.deliveries.clear
  end

  describe "after_initialize" do
    it "should create a random token of at least 6 characters" do
      gc = GiftCertificate.new
      gc.token.length.should >= 6
    end

    it "should retry if a duplicate is created" do
      old_gc = Fabricate(:gift_certificate, token: "123456")
      SecureRandom.stub(:urlsafe_base64).and_return("123456", "234567")
      gift_certificate = GiftCertificate.new
      expect(gift_certificate.token).to_not eq "123456"
      expect(gift_certificate.token).to eq "234567"
    end

  end

  describe ".purchase" do
    before(:each) do
      GiftCertificate.stub(:collect_money)
    end

    it "should call get_tax_info from acts_as_chargeable" do
      GiftCertificate.should_receive(:get_tax_info)
      GiftCertificate.purchase(purchaser, ip_address, assembly, discounted_price, stripe_token, gift_info)
    end
    it "should call send_email" do
      GiftCertificate.any_instance.should_receive(:send_email).with("nad@chefsteps.com")
      GiftCertificate.purchase(purchaser, ip_address, assembly, discounted_price, stripe_token, gift_info)
    end

    context "#collect_money" do
      it "should not collect money if user is an admin" do
        admin = Fabricate(:user, role: "admin")
        GiftCertificate.should_not_receive(:collect_money)
        GiftCertificate.purchase(admin, ip_address, assembly, discounted_price, stripe_token, gift_info)
      end

      it "should collect money if the user is not an admin" do
        GiftCertificate.should_receive(:collect_money)
        GiftCertificate.purchase(purchaser, ip_address, assembly, discounted_price, stripe_token, gift_info)
      end
    end

    context "no sales tax" do
      before(:each) do
        GiftCertificate.stub(:get_tax_info).and_return([19.00, 0.0, ""])
      end

      subject { GiftCertificate.purchase(purchaser, ip_address, assembly, discounted_price, stripe_token, gift_info) }
      its(:token){ should == "123456"}
      its(:purchaser_id){ should == purchaser.id }
      its(:assembly_id){ should == assembly.id }
      its(:price){ should == 19.00 }
      its(:sales_tax){ should == 0.0}
      its(:recipient_email){ should == "dan@chefsteps.com"}
      its(:recipient_name){ should == "Dan"}
      its(:recipient_message){should == "Testing"}

      it "should return a gift_certificate" do
        expect(GiftCertificate.purchase(purchaser, ip_address, assembly, discounted_price, stripe_token, gift_info)).to be_an_instance_of(GiftCertificate)
      end
    end

    context "has sales tax" do
      before(:each) do
        GiftCertificate.stub(:get_tax_info).and_return([17.84, 1.16, " (including $1.16 WA state sales tax)" ])
      end

      subject { GiftCertificate.purchase(purchaser, ip_address, assembly, discounted_price, stripe_token, gift_info) }
      its(:token){ should == "123456"}
      its(:purchaser_id){ should == purchaser.id }
      its(:assembly_id){ should == assembly.id }
      its(:price){ should == 17.84 }
      its(:sales_tax){ should == 1.16}
      its(:recipient_email){ should == "dan@chefsteps.com"}
      its(:recipient_name){ should == "Dan"}
      its(:recipient_message){should == "Testing"}

      it "should return a gift_certificate" do
        expect(GiftCertificate.purchase(purchaser, ip_address, assembly, discounted_price, stripe_token, gift_info)).to be_an_instance_of(GiftCertificate)
      end
    end
  end

  describe ".redeem" do
    subject { GiftCertificate.redeem(purchaser, gift_certificate.id) }

    it { subject.should be_an_instance_of Enrollment}
    its(:user_id){ should be purchaser.id }
    its(:enrollable){ should eq assembly }
    its(:gift_certificate_id){ should be gift_certificate.id }

    it "should set the gift_certiciate as redeemed" do
      GiftCertificate.redeem(purchaser, gift_certificate.id)
      gift_certificate.reload # Doing this because it's been updated and needs to be reloaded to show the value
      gift_certificate.redeemed.should be true
    end
  end

  describe "#send_email" do
    subject { gift_certificate.send_email("danahern@chefsteps.com") }
    it 'should send an email' do
      subject
      check_email(to: "danahern@chefsteps.com", from: "info@chefsteps.com", subject: "Purchaser gifted you the MyString Class on ChefSteps.")
    end
  end

  describe "#resend_email" do
    subject { gift_certificate.resend_email("danahern@chefsteps.com") }
    it 'should send an email' do
      subject
      check_email(to: "danahern@chefsteps.com", from: "info@chefsteps.com", subject: "Purchaser gifted you the MyString Class on ChefSteps.")
      email = ActionMailer::Base.deliveries.first
      email.body.raw_source.should include 'We noticed you did not redeem this gift.'
    end

    it 'should set followed up to true' do
      subject
      gift_certificate.followed_up.should eq(true)
    end
  end

end
