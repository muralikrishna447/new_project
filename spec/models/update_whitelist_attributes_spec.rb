require 'spec_helper'

describe User, 'UpdateWhitelistAttributes' do
  let(:user) { Fabricate(:user, id: 123) }
  it 'does not update attribute that is not in model whitelist' do
    user.update_whitelist_attributes({id: 2})
    user.id.should == 123
  end

  it 'updates attribute that is in model whitelist' do
    user.update_whitelist_attributes({id: 2, name: 'test'})
    user.name.should == 'test'
  end
end
