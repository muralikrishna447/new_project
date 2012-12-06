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

describe Quiz, "update_question_order" do
  let(:quiz) { Fabricate(:quiz) }
  let(:questionA) { Fabricate(:multiple_choice_question) }
  let(:questionB) { Fabricate(:multiple_choice_question) }
  let(:question_ids) { [ questionA.id, questionB.id ].map(&:to_s) }

  before do
    quiz.questions << questionB << questionA
    quiz.update_question_order(question_ids)
  end

  it "updates the order of the questions" do
    quiz.questions.ordered.should == [questionA, questionB]
  end
end

describe Quiz, "#questions_answered_by" do
  let(:user) { Fabricate.build(:user, id: 100) }
  let(:other_user) { Fabricate.build(:user, id: 200) }
  let(:quiz) { Fabricate(:quiz) }
  let(:questionA) { Fabricate(:multiple_choice_question) }
  let(:questionB) { Fabricate(:multiple_choice_question) }

  before do
    quiz.questions << questionA << questionB
  end

  subject { quiz.questions_answered_by(user) }

  it 'uses ordered questions' do
    questions = quiz.ordered_questions
    quiz.should_receive(:ordered_questions).and_return(questions)
    subject
  end

  it 'returns empty collection when user has answered no questions' do
    should =~ []
  end

  it 'returns answered question if user has answered first question' do
    Fabricate(:multiple_choice_answer, user: user, question: questionA)
    should =~ [questionA]
  end

  it 'returns empty collection if other user has answered first question' do
    Fabricate(:multiple_choice_answer, user: other_user, question: questionA)
    should =~ []
  end

  it 'returns all questions if user has answered all questions' do
    Fabricate(:multiple_choice_answer, user: user, question: questionA)
    Fabricate(:multiple_choice_answer, user: user, question: questionB)
    should =~ [questionA, questionB]
  end
end

describe Quiz, "#questions_remaining_for" do
  let(:user) { Fabricate.build(:user, id: 100) }
  let(:other_user) { Fabricate.build(:user, id: 200) }
  let(:quiz) { Fabricate(:quiz, id: 200) }
  let(:questionA) { Fabricate.build(:multiple_choice_question) }
  let(:questionB) { Fabricate.build(:multiple_choice_question) }

  before do
    quiz.questions << questionA << questionB
  end

  subject { quiz.questions_remaining_for(user) }

  it 'returns all questions when user has answered no questions' do
    quiz.should_receive(:questions_answered_by).with(user) { [] }
    should =~ [questionA, questionB]
  end

  it 'returns unanswered question if user has answered first question' do
    quiz.should_receive(:questions_answered_by).with(user) { [questionA] }
    should =~ [questionB]
  end

  it 'returns empty collection if user has answered all questions' do
    quiz.should_receive(:questions_answered_by).with(user) { [questionA, questionB] }
    should =~ []
  end
end

describe Quiz, '#started_by?' do
  let(:user) { Fabricate.build(:user) }
  let(:quiz) { Fabricate(:quiz) }

  it 'returns false if user has answered no questions' do
    quiz.should_receive(:questions_answered_by).with(user) { [] }
    quiz.started_by?(user).should_not be
  end

  it 'returns true if user has answered questions' do
    quiz.should_receive(:questions_answered_by).with(user) { ['q1'] }
    quiz.started_by?(user).should be
  end
end
