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

describe QuizHelper, '#estimated_time' do
  it 'is 0 if there are no questions' do
    helper.estimated_time(0).should == 0
  end

  it 'adds 20 seconds for every question, rounded to the minute' do
    helper.estimated_time(2).should == 0
    helper.estimated_time(3).should == 1
    helper.estimated_time(6).should == 2
  end
end
