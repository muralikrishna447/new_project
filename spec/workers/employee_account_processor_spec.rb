require 'spec_helper'

describe EmployeeAccountProcessor do
  describe 'has_employee_email?' do
    let(:user) { User.new(email: email) }

    context 'email ends with employee domain' do
      let(:email) { 'test@breville.com' }

      it 'returns true' do
        expect(EmployeeAccountProcessor.has_employee_email?(user)).to be_true
      end
    end

    context 'email does not end with employee domain' do
      let(:email) { 'a@b.com' }

      it 'returns false' do
        expect(EmployeeAccountProcessor.has_employee_email?(user)).to be_false
      end
    end
  end
end
