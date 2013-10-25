require 'spec_helper'

describe Enrollment do
  before :each do
    @user = Fabricate :user, email: 'test@test.com', name: 'Test User'
    @course = Fabricate :course, title: 'Test Course'
    @assembly = Fabricate :assembly, title: 'Test Assembly'
    @paid_assembly = Fabricate :assembly, title: 'Cooking For the Hirsute', price: 39, id: 37
  end
  
  it 'should return a course object when a @user enrolls into a course' do
    enrollment = Fabricate :enrollment, user: @user, enrollable: @course
    expect(enrollment.enrollable).to be_an_instance_of(Course)
  end

  it 'should return a course object when a @user enrolls into a course' do
    enrollment = Fabricate :enrollment, user: @user, enrollable: @assembly
    expect(enrollment.enrollable).to be_an_instance_of(Assembly)
  end

  it 'should not allow a @user to enroll into the same course twice' do
    enrollment1 = Fabricate :enrollment, user: @user, enrollable: @assembly
    enrollment2 = Fabricate.build(:enrollment, user: @user, enrollable: @assembly)
    enrollment1.should be_valid
    enrollment2.should_not be_valid
  end

  context 'Charging for classes do' do

    before do
      Stripe::Customer.stub(:create).and_return(Stripe::Customer.new)
      Stripe::Customer.any_instance.stub(:id).and_return('BARGLE')
      @double_loc = double(Object)
      Geokit::Geocoders::IpGeocoder.should_receive(:geocode).and_return(@double_loc)
    end    

    context 'ip based tax calculations ' do

      before do
        Stripe::Customer.should_receive(:create)
      end 

      it 'rolls back Enrollment if charge fails' do
        @double_loc.stub(:state).and_return("NJ")
        Stripe::Charge.should_receive(:create).and_raise(Stripe::StripeError)
        expect {
          Enrollment.enroll_user_in_assembly(@user, "ignored", @paid_assembly, 39.00, "ignored")
        }.to raise_error
        expect(Enrollment.count).to eq(0)
      end       

      it 'stores correct price and tax in enrollment in a no tax situation' do
        @double_loc.stub(:state).and_return("NJ")
        Stripe::Charge.should_receive(:create).with(hash_including({description: "Cooking For the Hirsute"}))
        enrollment = Enrollment.enroll_user_in_assembly(@user, "ignored", @paid_assembly, 39.00, "ignored")
        expect(enrollment.price).to eq(39.00)
        expect(enrollment.sales_tax).to eq(0.00)
        expect(Enrollment.count).to eq(1)
      end

      it 'stores correct price and tax in enrollment in a taxed situation' do        
        @double_loc.stub(:state).and_return("WA")
        Stripe::Charge.should_receive(:create).with(hash_including({description: "Cooking For the Hirsute (including $3.38 WA state sales tax)"}))
        enrollment = Enrollment.enroll_user_in_assembly(@user, "ignored", @paid_assembly, 39.00, "ignored")
        expect(enrollment.price).to eq(35.62)
        expect(enrollment.sales_tax).to eq(3.38)
        expect(Enrollment.count).to eq(1)
      end


    end
  end
end
