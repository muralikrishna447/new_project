require 'spec_helper'

describe Step, '#title' do
  let(:step) { Step.new }

  it "returns '' if no index provided and step has no title" do
    step.title.should be_blank
  end

  it "returns 'Step INDEX+1' if index provided and step has no title" do
    step.title(5).should == "Step 6"
  end

  it "returns title if step has title" do
    step.title = 'the title'
    step.title.should == 'the title'
  end

end
