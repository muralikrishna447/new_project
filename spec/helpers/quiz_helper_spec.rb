require 'spec_helper'

describe QuizHelper, '#show_quizzes?' do
  subject { helper.show_quizzes? }

  it 'does not show_quizzes feature flag is false' do
    Rails.stub_chain(:application, :config, :show_quizzes) { false }
    should_not be
  end

  it 'does show if show_quizzes feature flag is true' do
    Rails.stub_chain(:application, :config, :show_quizzes) { true }
    should be
  end
end
