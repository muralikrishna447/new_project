require "spec_helper"

describe DeclinedMailer do
  let(:user) { Fabricate(:user, name: "Test User", email: 'test@example.com')}

  before(:each) do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    WebMock.stub_request(:post, "https://mandrillapp.com/api/1.0/templates/render.json").
      to_return(:status => 200, :body => {html: "<p><div>content to inject merge1 content<\/div><\/p>"}.to_json, :headers => {})
  end

  after(:each) do
    ActionMailer::Base.deliveries.clear
  end

  describe "joule declined message" do
    before(:each) do
      DeclinedMailer.joule(user).deliver
    end

    it "should send an email" do
      ActionMailer::Base.deliveries.count.should == 1
    end

    it "should go to the user's email" do
      ActionMailer::Base.deliveries.first.to.should == ['test@example.com']
    end

    it "should have the subject of" do
      ActionMailer::Base.deliveries.first.subject.should == "ChefSteps Joule Payment - Your card was declined"
    end

    it "should set the from correctly" do
      ActionMailer::Base.deliveries.first.from.should == ['ellenk@chefsteps.com']
    end
  end

  describe "premium declined message" do
    before(:each) do
      DeclinedMailer.premium(user).deliver
    end

    it "should send an email" do
      ActionMailer::Base.deliveries.count.should == 1
    end

    it "should go to the user's email" do
      ActionMailer::Base.deliveries.first.to.should == ['test@example.com']
    end

    it "should have the subject of" do
      ActionMailer::Base.deliveries.first.subject.should == "ChefSteps Premium Payment - Your card was declined"
    end

    it "should set the from correctly" do
      ActionMailer::Base.deliveries.first.from.should == ['ellenk@chefsteps.com']
    end
  end
end
