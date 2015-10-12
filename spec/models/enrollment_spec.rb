require 'spec_helper'

describe Enrollment do
  before :each do
    @user = Fabricate :user, email: 'test@test.com', name: 'Test User'
    @assembly = Fabricate :assembly, title: 'Test Assembly', assembly_type: "Course"
    @paid_assembly = Fabricate :assembly, title: 'Cooking For the Hirsute', price: 39, assembly_type: "Course"
  end

  # context 'Charging for classes do' do

  #   before do
  #     Stripe::Customer.stub(:create).and_return(Stripe::Customer.new)
  #     Stripe::Customer.any_instance.stub(:id).and_return('BARGLE')
  #     @double_loc = double(Object)
  #     Geokit::Geocoders::IpGeocoder.should_receive(:geocode).and_return(@double_loc)
  #   end

  #   context 'ip based tax calculations ' do

  #     before do
  #       Stripe::Customer.should_receive(:create)
  #     end

  #     it 'rolls back Enrollment if charge fails' do
  #       @double_loc.stub(:state).and_return("NJ")
  #       Stripe::Charge.should_receive(:create).and_raise(Stripe::StripeError)
  #       expect {
  #         Enrollment.enroll_user_in_assembly(@user, "ignored", @paid_assembly, 39.00, "ignored")
  #       }.to raise_error
  #       expect(Enrollment.count).to eq(0)
  #     end

  #     it 'stores correct price and tax in enrollment in a no tax situation' do
  #       @double_loc.stub(:state).and_return("NJ")
  #       Stripe::Charge.should_receive(:create).with(hash_including({description: "Cooking For the Hirsute"}))
  #       enrollment = Enrollment.enroll_user_in_assembly(@user, "ignored", @paid_assembly, 39.00, "ignored")
  #       expect(enrollment.price).to eq(39.00)
  #       expect(enrollment.sales_tax).to eq(0.00)
  #       expect(Enrollment.count).to eq(1)
  #     end

  #     it 'stores correct price and tax in enrollment in a taxed situation' do
  #       @double_loc.stub(:state).and_return("WA")
  #       Stripe::Charge.should_receive(:create).with(hash_including({description: "Cooking For the Hirsute (including $3.38 WA state sales tax)"}))
  #       enrollment = Enrollment.enroll_user_in_assembly(@user, "ignored", @paid_assembly, 39.00, "ignored")
  #       expect(enrollment.price).to eq(35.62)
  #       expect(enrollment.sales_tax).to eq(3.38)
  #       expect(Enrollment.count).to eq(1)
  #     end
  #   end
  # end

  let(:purchaser){ Fabricate(:user, name: "Purchaser", email: "test@chefsteps.com") }
  let(:ip_address) { "10.0.0.1" }
  let(:assembly) { Fabricate(:assembly, price: 39.00, assembly_type: "Course") }
  let(:discounted_price) { 19.99 }
  let(:stripe_token) { "12345" }
  let(:gift_info) { {"recipientEmail" => "dan@chefsteps.com", "recipientName" => "Dan", "recipientMessage" => "Testing", "emailToRecipient" => "nad@chefsteps.com"} }
  let(:gift_certificate){ Fabricate(:gift_certificate, assembly_id: assembly.id, redeemed: false, purchaser_id: purchaser.id, recipient_email: "danahern@chefsteps.com", recipient_name: "Dan Ahern Recipient", recipient_message: "Enjoy") }

  describe ".enroll_user_in_assembly" do
    context "test without outside modules" do
      before(:each) do
        Enrollment.stub(:get_tax_info).and_return([19.00, 0.0, ""])
        Enrollment.stub(:collect_money)
      end
      it "should return an enrollment" do
        Enrollment.enroll_user_in_assembly(purchaser, ip_address, assembly, discounted_price, stripe_token).should be_an_instance_of Enrollment
      end

      it "should create an enrollment" do
        expect{ Enrollment.enroll_user_in_assembly(purchaser, ip_address, assembly, discounted_price, stripe_token) }.to change(Enrollment, :count).by(1)
      end

      context "paid class" do
        subject{ Enrollment.enroll_user_in_assembly(purchaser, ip_address, assembly, discounted_price, stripe_token) }
        its(:user_id){ should eq purchaser.id }
        its(:enrollable){ should eq assembly }
        its(:price){ should eq 19.00 }
        its(:sales_tax){ should eq 0.0 }

        it "should call paid_enrollment" do
          Enrollment.should_receive(:paid_enrollment)
          subject
        end

        it "should call get_tax_info" do
          Enrollment.should_receive(:get_tax_info).and_return([19.00, 0.0, ""])
          Enrollment.enroll_user_in_assembly(purchaser, ip_address, assembly, discounted_price, stripe_token)
        end

        it "should call collect_money" do
          Enrollment.should_receive(:collect_money)
          Enrollment.enroll_user_in_assembly(purchaser, ip_address, assembly, discounted_price, stripe_token)
        end

        context "with tax" do
          before(:each) do
            Enrollment.stub(:get_tax_info).and_return([17.84, 1.16, " (including $1.16 WA state sales tax)" ])
          end

          subject{ Enrollment.enroll_user_in_assembly(purchaser, ip_address, assembly, discounted_price, stripe_token) }
          its(:user_id){ should eq purchaser.id }
          its(:enrollable){ should eq assembly }
          its(:price){ should eq 17.84 }
          its(:sales_tax){ should eq 1.16 }
        end
      end

      context "free class" do
        let(:free_assembly) { Fabricate(:assembly, price: 0, assembly_type: "Course") }
        subject{ Enrollment.enroll_user_in_assembly(purchaser, ip_address, free_assembly, discounted_price, stripe_token) }
        its(:user_id){ should eq purchaser.id }
        its(:enrollable){ should eq free_assembly }
        its(:price){ should eq 0.0 }
        its(:sales_tax){ should eq 0.0 }

        it "should call free_enrollment" do
          Enrollment.should_receive(:free_enrollment)
          subject
        end

        it "should not call get_tax_info" do
          Enrollment.should_not_receive(:get_tax_info)
          subject
        end

        it "should not call collect_money" do
          Enrollment.should_not_receive(:collect_money)
          subject
        end
      end
    end

    context "#paid_enrollment" do
      before(:each) do
        Enrollment.stub(:get_tax_info).and_return([19.00, 0.0, ""])
        Enrollment.stub(:collect_money)
      end

      subject { Enrollment.paid_enrollment(purchaser, ip_address, assembly, discounted_price, stripe_token, 0) }
      # its(:user_id){ should eq purchaser.id }
      # its(:enrollable){ should eq assembly }
      # its(:price){ should eq 19.00 }
      # its(:sales_tax){ should eq 0.0 }

      it "should call get_tax_info" do
        Enrollment.should_receive(:get_tax_info).and_return([19.00, 0.0, ""])
        subject
      end

      it "should call collect_money" do
        Enrollment.should_receive(:collect_money)
        subject
      end

      it "should create a record" do
        expect{subject}.to change(Enrollment, :count).by(1)
      end
    end

    context "#free_enrollment" do
      let(:free_assembly) { Fabricate(:assembly, price: 0, assembly_type: "Course") }
      subject { Enrollment.free_enrollment(purchaser, ip_address, free_assembly, discounted_price, stripe_token) }
      its(:user_id){ should eq purchaser.id }
      its(:enrollable){ should eq free_assembly }
      its(:price){ should eq 0.0 }
      its(:sales_tax){ should eq 0.0 }

      it "should create a record" do
        expect{subject}.to change(Enrollment, :count).by(1)
      end
    end

    context "test with outside modules" do
      it "should raise an error if there is a problem with stripe" do
        Stripe::Customer.should_receive(:create).and_raise(Stripe::StripeError)
        expect{Enrollment.enroll_user_in_assembly(purchaser, ip_address, assembly, discounted_price, stripe_token)}.to raise_error
      end

      it "should roll back the transaction on error" do
        Stripe::Customer.should_receive(:create).and_raise(ActiveRecord::Rollback) # Because otherwise it just raises an error and we can't test the rollback
        expect{Enrollment.enroll_user_in_assembly(purchaser, ip_address, assembly, discounted_price, stripe_token)}.to change(Enrollment, :count).by(0)
      end
    end
  end
end
