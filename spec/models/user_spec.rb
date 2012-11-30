require 'spec_helper'

describe User, '#profile_complete?' do
  let(:user) { Fabricate.build(:user) }
  it 'is incomplete on new user' do
    user.profile_complete?.should_not be
  end

  it 'is complete if chef_type is specified' do
    user.chef_type = 'professional_chef'
    user.profile_complete?.should be
  end
end
