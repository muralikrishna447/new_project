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
  let(:quiz) { stub('quiz', questions: []) }

  it 'is 0 if there are no questions' do
    helper.estimated_time(quiz).should == 0
  end

  it 'adds 20 seconds for every question, rounded to the minute' do
    quiz.questions.push(1, 2)
    helper.estimated_time(quiz).should == 0
    quiz.questions.push(3)
    helper.estimated_time(quiz).should == 1
    quiz.questions.push(4, 5, 6)
    helper.estimated_time(quiz).should == 2
  end
end
