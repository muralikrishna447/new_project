require 'spec_helper'

describe Quiz, '#add_multiple_choice_question' do
  let(:quiz) { Fabricate(:quiz) }

  it "creates a new MultipleChoiceQuestion" do
    question = quiz.add_multiple_choice_question
    question.should be_a MultipleChoiceQuestion
    question.should be_persisted
  end

  it "adds question to quiz's questions association" do
    quiz.add_multiple_choice_question
    quiz.questions.should have(1).question
  end
end

describe Quiz, '#question_count' do
  let(:quiz) { Fabricate(:quiz) }
  it 'should return count of questions' do
    quiz.add_multiple_choice_question
    quiz.question_count.should == 1
  end
end
