require 'spec_helper'

describe Presenter, "#initialize" do
  let(:model) { mock('model') }
  subject { Presenter.new(model) }

  it "sets the present model" do
    subject.model.should == model
  end
end

