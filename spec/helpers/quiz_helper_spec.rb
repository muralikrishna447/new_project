require 'spec_helper'

describe QuizHelper, '#show_quizzes?' do
  before { helper.stub(:user_signed_in?) { false } }

  subject { helper.show_quizzes? }

  it 'does not show if user is not authenticated' do
    should_not be
  end

  context 'user is authenticated' do
    before { helper.stub(:user_signed_in?) { true } }
    it 'shows if user' do
      should be
    end

    it 'does not show_quizzes feature flag is false' do
      Rails.stub_chain(:application, :config, :show_quizzes) { false }
      should_not be
    end
  end
end
