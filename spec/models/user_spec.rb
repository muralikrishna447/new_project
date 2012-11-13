require 'spec_helper'

describe User, '#to_json' do
  subject { JSON.parse(Fabricate.build(:user).to_json) }

  it "only serializes valid keys" do
    subject.keys.should =~ %w[id email name location quote website]
  end
end
