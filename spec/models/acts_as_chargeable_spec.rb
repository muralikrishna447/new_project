require 'spec_helper'

class Dummy
  include ActsAsChargeable
end

describe ActsAsChargeable do
  let(:user){ Fabricate(:user) }

  describe ".get_tax_info" do
    it "should have a get_tax_info method" do
      (Dummy.methods-Object.methods).should include(:get_tax_info)
    end

    context "paid class" do
      before(:each) do
        Dummy.stub(:adjust_for_included_tax).and_return([17.84, 1.16])
        Dummy.stub(:get_tax_description).and_return("including 1.16 WA state sales tax")
      end

      it "should return gross_price, tax and extra_descript" do
        Dummy.get_tax_info(39.00, 19.00, "127.0.0.1").should eq [17.84, 1.16, "including 1.16 WA state sales tax"]
      end

      it "should call adjust_for_included_tax" do
        Dummy.should_receive(:adjust_for_included_tax)
        Dummy.get_tax_info(39.00, 19.00, "127.0.0.1")
      end

      it "should call get_tax_description" do
        Dummy.should_receive(:get_tax_description)
        Dummy.get_tax_info(39.00, 19.00, "127.0.0.1")
      end
    end

    context "free class" do
      it "should return 0s and no description if base_price is 0" do
        Dummy.get_tax_info(0,0,"127.0.0.1").should eq [0,0,""]
      end

      it "should not call adjust_for_included_tax" do
        Dummy.should_not_receive(:adjust_for_included_tax)
        Dummy.get_tax_info(0,0,"127.0.0.1").should eq [0,0,""]
      end

      it "should not call get_tax_description" do
        Dummy.should_not_receive(:get_tax_description)
        Dummy.get_tax_info(0,0,"127.0.0.1").should eq [0,0,""]
      end
    end
  end

  describe ".collect_money" do
    let(:user){ Fabricate(:user, stripe_id: "123") }
    let(:new_user){ Fabricate(:user) }
    let(:card){ double('card') }

    it "should have a collect_money method" do
      (Dummy.methods-Object.methods).should include(:collect_money)
    end

    context "free class" do
      it "should not call Stripe::Charge" do
        Stripe::Charge.should_not_receive(:create)
        Dummy.collect_money(0, 0, "Become a Badass for Free", "", user, nil, nil)
      end

      it "should do nothing if price is 0" do
        Dummy.should_not_receive(:set_stripe_id_on_user)
        Dummy.collect_money(0, 0, "Become a Badass for Free", "", user, nil, nil)
      end
    end

    context "paid class" do
      before(:each) do
        Dummy.stub(:set_stripe_id_on_user)
        Stripe::Charge.stub(:create)
        customer = double('customer')
        customer.stub(:cards)

        Stripe::Customer.stub(:retrieve).and_return(customer)
        card.stub(:id)
        customer.cards.stub(:create).and_return(card)
      end

      # it "should call stripe charge if there is a stripe token" do
      #   Stripe::Charge.should_receive(:create).with(customer: "123", amount: 1900, description: "Become a Badass", currency: "usd", card: card.id)
      #   Dummy.collect_money(39.00, 19.00, "Become a Badass", "", user, "123456", nil)
      # end

      # it "should call stripe charge if there isn't a stripe token" do
      #   Stripe::Charge.should_receive(:create).with(customer: "123", amount: 1900, description: "Become a Badass", currency: "usd")
      #   Dummy.collect_money(39.00, 19.00, "Become a Badass", "", user, nil, nil)
      # end

      it "should call stripe charge for new customers" do
        Stripe::Charge.should_receive(:create).with(customer: nil, amount: 1900, description: "Become a Badass", currency: "usd")
        Dummy.collect_money(39.00, 19.00, "Become a Badass", "", new_user, "123456", nil)
      end

    end
  end

  describe ".adjust_for_included_tax" do
    context "inside of washington" do
      before(:each) do
        location = double('location')
        location.stub(:state).and_return("WA")
        Geokit::Geocoders::IpGeocoder.stub(:geocode).and_return(location)
      end
      it "should return the price minus tax and the tax" do
        Dummy.adjust_for_included_tax(19.00, "127.0.0.1").should eq [17.35, 1.65]
      end
    end

    context "outside of washington" do
      before(:each) do
        location = double('location')
        location.stub(:state).and_return("OR")
        Geokit::Geocoders::IpGeocoder.stub(:geocode).and_return(location)
      end
      it "should return the price and 0 tax" do
        Dummy.adjust_for_included_tax(19.00, "127.0.0.1").should eq [19.00, 0]
      end
    end
  end

  describe ".get_tax_description" do
    context "with tax" do
      it "should return a description with the tax information" do
        Dummy.get_tax_description(1.65).should eq " (including $1.65 WA state sales tax)"
      end
    end

    context "without tax" do
      it "should not return any description with tax" do
        Dummy.get_tax_description(0).should eq ""
      end
    end
  end

  describe ".set_stripe_id_on_user" do
    context "user has no stripe_id" do
      before(:each) do
        customer =  double("customer")
        customer.stub(:id).and_return("987")
        Stripe::Customer.stub(:create).and_return(customer)
      end

      it "should set the stripe_id for the user" do
        Dummy.set_stripe_id_on_user(user, "456")
        user.reload # Reloading because something happened
        user.stripe_id.should eq "987"
      end
    end

    context "user has a stripe_id" do
      let(:user){ Fabricate(:user, email: "test@example.com", stripe_id: "123") }
      let(:customer){ Stripe::Customer.new}

      before(:each) do
        Stripe::Customer.stub(:retrieve).and_return(customer)
        customer.stub(:save)
      end

      it "should set the card to the token" do
        Dummy.set_stripe_id_on_user(user, "456")
        customer.card.should eq "456"
      end

      it "should set the email of the card to the users email" do
        Dummy.set_stripe_id_on_user(user, "456")
        customer.email.should eq "test@example.com"
      end

      it "should call save on the customer" do
        customer.should_receive(:save)
        Dummy.set_stripe_id_on_user(user, "456")
      end
    end
  end
end