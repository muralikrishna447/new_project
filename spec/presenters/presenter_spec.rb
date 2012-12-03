require 'spec_helper'

describe Presenter, "#initialize" do
  let(:model) { mock('model') }
  subject { Presenter.new(model) }

  it "sets the present model" do
    subject.model.should == model
  end
end

describe Presenter, "#present" do
  let(:presenter) { Presenter.new(stub) }

  it "converts attributes to json" do
    presenter.stub(:attributes) { {test: 2} }
    presenter.present.should == "{\"test\":2}"
  end
end

describe Presenter, "#present_collection" do
  let(:collection) { [stub, stub, stub] }

  it "presents each item in collection" do
    presented = JSON.parse(Presenter.present_collection(collection))
    presented.should have(3).items
  end

  it "passes optional args to constructor" do
    stub_presenter = stub('presenter', wrapped_attributes: '')
    Presenter.should_receive(:new).with(anything, 'arg').exactly(3).times.and_return(stub_presenter)
    Presenter.present_collection(collection, 'arg')
  end
end
