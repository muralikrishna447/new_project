require 'spec_helper'

describe ActiveAdmin::ViewsHelper do
  let(:activity) { Fabricate.build(:activity) }

  it 'returns yes if promoted_order is present' do
    activity.is_promoted = '1'
    activity.promote_order = 1
    activity.save!

    expect(helper.activity_promoted?(activity)).to eq 'Yes'
  end

  it 'returns no if promoted_order is nil' do
    activity.is_promoted = '0'
    activity.promote_order = nil
    activity.save!

    expect(helper.activity_promoted?(activity)).to eq 'No'
  end
end
