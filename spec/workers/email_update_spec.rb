require 'spec_helper'

describe EmailUpdate do
  let(:user) {
    Fabricate :user, id: 456, email: 'johndoe@chefsteps.com'
  }
  let(:email_update_result) {
    true
  }

  context 'Update Email of user' do
    before(:each) do
      @new_user = user.save
    end

    it 'User sync queue after email updated' do
      EmailUpdate.should_receive(:perform)
                 .with(user.id, 'old_email@test.com', user.email)
                 .and_return(email_update_result)
      expect(EmailUpdate.perform(user.id, 'old_email@test.com', user.email)).to be true
    end

    it 'should throw error if email is not same as in user' do
      expect {EmailUpdate.perform(user.id, 'old_email@test.com','invalid@test.com')}.to raise_error("Current email [johndoe@chefsteps.com] does not match expected [invalid@test.com]")
    end
  end

end
