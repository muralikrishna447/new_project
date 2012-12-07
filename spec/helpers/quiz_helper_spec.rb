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

describe QuizHelper, '#estimated_mins' do
  it 'is 1 minute if there are less than 3 questions' do
    helper.estimated_mins(0).should == 1
    helper.estimated_mins(1).should == 1
    helper.estimated_mins(2).should == 1
  end

  it 'adds 1 minute for every 3 questions' do
    helper.estimated_mins(3).should == 1
    helper.estimated_mins(4).should == 1
    helper.estimated_mins(6).should == 2
    helper.estimated_mins(9).should == 3
  end
end

describe QuizHelper, '#estimated_secs' do
  it 'is 0s if there are no questions' do
    helper.estimated_secs(0).should == 0
  end

  it 'adds 20 seconds for every question, rounded to the minute' do
    helper.estimated_secs(2).should == 40
    helper.estimated_secs(3).should == 60
    helper.estimated_secs(6).should == 120
  end
end

describe QuizHelper, 'question stats' do
  let(:user) { stub }
  let(:quiz) { stub }

  before do
    helper.stub(:current_user) { user }
    quiz.should_receive(:questions_answered_by_count) { 3 }
    quiz.should_receive(:question_count) { 20 }
  end

  context '#question_count_stats' do
    it 'returns [# questions answered, # total questions]' do
      helper.question_count_stats(quiz).should == [3, 20]
    end
  end

  context '#question_time_stats' do
    it 'returns [est_time(# questions answered), est_time(# total questions)]' do
      helper.question_time_stats(quiz).should == [60, 400]
    end
  end
end
