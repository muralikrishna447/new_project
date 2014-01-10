require 'spec_helper'

describe Quiz, '#add_question' do
  let(:quiz) { Fabricate(:quiz) }

  it "adds question to quiz's questions association" do
    quiz.add_question(:multiple_choice_question)
    quiz.questions.should have(1).question
  end

  it "creates a new MultipleChoiceQuestion if multiple_choice_question type specified" do
    question = quiz.add_question(:multiple_choice_question)
    question.should be_a MultipleChoiceQuestion
    question.should be_persisted
  end

  it "creates a new BoxSortQuestion if box_sort_question type specified" do
    question = quiz.add_question(:box_sort_question)
    question.should be_a BoxSortQuestion
    question.should be_persisted
  end

end

describe Quiz, '#question_count' do
  let(:quiz) { Fabricate(:quiz) }

  it 'should return count of questions' do
    quiz.add_question(:multiple_choice_question)
    quiz.question_count.should == 1
  end
end

describe Quiz, "update_question_order" do
  let(:quiz) { Fabricate(:quiz) }
  let(:questionA) { Fabricate(:multiple_choice_question) }
  let(:questionB) { Fabricate(:box_sort_question) }
  let(:questionC) { Fabricate(:multiple_choice_question) }
  let(:question_ids) { [ questionA.id, questionB.id, questionC.id ] }

  before do
    quiz.questions << questionB << questionC << questionA
    quiz.update_question_order(question_ids.map(&:to_s))
  end

  it "updates the order of the questions" do
    quiz.questions.ordered.map(&:id).should == question_ids
  end

  it 'does not change the type of the question' do
    quiz.questions.ordered.first.should be_a MultipleChoiceQuestion
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

  it 'clears all answers on retake without affecting other user' do
    Fabricate(:multiple_choice_answer, user: user, question: questionA)
    Fabricate(:multiple_choice_answer, user: user, question: questionB)
    Fabricate(:multiple_choice_answer, user: other_user, question: questionA)
    quiz.destroy_answers_for(user)
    should =~ []
    quiz.questions_answered_by(other_user).should =~ [questionA]
  end
end

describe Quiz, '#questions_answered_by_count' do
  let(:user) { stub }
  let(:quiz) { Fabricate(:quiz) }

  it 'returns count of questions answered by user' do
    quiz.should_receive(:questions_answered_by).with(user) { ['q1', 'q2'] }
    quiz.questions_answered_by_count(user).should == 2
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

describe Quiz, '#questions_remaining_for_count' do
  let(:user) { stub }
  let(:quiz) { Fabricate(:quiz) }

  it 'returns count of questions remaining for user' do
    quiz.should_receive(:questions_remaining_for).with(user) { ['q1', 'q2', 'q3'] }
    quiz.questions_remaining_for_count(user).should == 3
  end
end

describe Quiz, '#started_by?' do
  let(:user) { stub }
  let(:quiz) { Fabricate(:quiz) }

  it 'returns false if user has answered no questions' do
    quiz.should_receive(:questions_answered_by_count).with(user) { 0 }
    quiz.started_by?(user).should_not be
  end

  it 'returns true if user has answered questions' do
    quiz.should_receive(:questions_answered_by_count).with(user) { 100 }
    quiz.started_by?(user).should be
  end
end

describe Quiz, '#completed_by?' do
  let(:user) { stub }
  let(:quiz) { Fabricate(:quiz) }

  it 'returns false if quiz has no questions' do
    quiz.stub(:question_count) { 0 }
    quiz.completed_by?(user).should_not be
  end

  it 'returns false if user has not answered all questions' do
    quiz.stub(:question_count) { 11 }
    quiz.should_receive(:questions_remaining_for_count).with(user) { 10 }
    quiz.completed_by?(user).should_not be
  end

  it 'returns true if user has answered all questions' do
    quiz.stub(:question_count) { 11 }
    quiz.should_receive(:questions_remaining_for_count).with(user) { 0 }
    quiz.completed_by?(user).should be
  end
end

describe Quiz, "#started_count" do
  let(:quiz) { Fabricate.build(:quiz) }
  let(:question) { Fabricate.build(:multiple_choice_question) }

  before do
    question.stub(:answer_count).and_return(2)
    quiz.stub_chain(:ordered_questions, :first).and_return(question)
  end

  subject { quiz.started_count }

  it "returns number of people that have started the quiz" do
    subject.should == 2
  end

end

describe Quiz, "#completed_count" do
  let(:quiz) { Fabricate.build(:quiz) }
  let(:question) { Fabricate.build(:multiple_choice_question) }

  before do
    question.stub(:answer_count).and_return(5)
    quiz.stub_chain(:ordered_questions, :last).and_return(question)
  end

  subject { quiz.completed_count}

  it "returns number of people that have completed the quiz" do
    subject.should == 5
  end

end

