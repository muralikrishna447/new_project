require 'spec_helper'

describe PremiumGiftCertificate do
  let(:purchaser){ Fabricate(:user, name: "Purchaser", email: "test@chefsteps.com") }
  let(:recipient){ Fabricate(:user, name: "Recipient", email: "recipient@aol.com") }
  let(:premium_gift_certificate){ Fabricate(:premium_gift_certificate, redeemed: false, purchaser_id: purchaser.id, price: 10, sales_tax: 1) }

  before(:each) do
    SecureRandom.stub(:urlsafe_base64).and_return("123456", "234567")
  end

  describe "after_initialize" do
    it "should create a random token of at least 6 characters" do
      gc = PremiumGiftCertificate.new
      gc.token.length.should >= 6
    end

    it "should retry if a duplicate is created" do
      old_gc = Fabricate(:premium_gift_certificate, token: "123456")
      SecureRandom.stub(:urlsafe_base64).and_return("123456", "234567")
      gift_certificate = PremiumGiftCertificate.new
      expect(gift_certificate.token).to_not eq "123456"
      expect(gift_certificate.token).to eq "234567"
    end

  end

  describe "#redeem" do
    before(:each) do
      @pgc = PremiumGiftCertificate.create
    end

    it "should set the gift_certificate as redeemed" do
      PremiumGiftCertificate.redeem(recipient, @pgc.token)
      @pgc.reload # Doing this because it's been updated and needs to be reloaded to show the value
      @pgc.redeemed.should be true
    end

    it "should error if double redeemed" do
      PremiumGiftCertificate.redeem(recipient, @pgc.token)
      expect { PremiumGiftCertificate.redeem(recipient, @pgc.token) }.to raise_error
    end

    it "should error if bogus token" do
      expect { PremiumGiftCertificate.redeem(recipient, "foofnick") }.to raise_error
    end
  end
end
