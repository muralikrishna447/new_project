describe Answer, '#increment_question_statistics' do
  let(:question) { Fabricate(:multiple_choice_question, correct_answer_count: 1, incorrect_answer_count: 1) }
  let(:answer) { Fabricate.build(:multiple_choice_answer, question: question, correct: @correct) }

  it "increments question's correct answer count if answer is correct" do
    @correct = true
    answer.send(:increment_question_statistics)
    question.correct_answer_count.should == 2
    question.incorrect_answer_count.should == 1
  end

  it "increments question's correct answer count if answer is incorrect" do
    @correct = false
    answer.send(:increment_question_statistics)
    question.correct_answer_count.should == 1
    question.incorrect_answer_count.should == 2
  end
end

describe Answer, '#decrement_question_statistics' do
  let(:question) { Fabricate(:multiple_choice_question, correct_answer_count: 1, incorrect_answer_count: 1) }
  let(:answer) { Fabricate.build(:multiple_choice_answer, question: question, correct: @correct) }

  it "decrements question's correct answer count if answer was correct" do
    @correct = true
    answer.send(:decrement_question_statistics)
    question.correct_answer_count.should == 0
    question.incorrect_answer_count.should == 1
  end

  it "increments question's correct answer count if answer is incorrect" do
    @correct = false
    answer.send(:decrement_question_statistics)
    question.correct_answer_count.should == 1
    question.incorrect_answer_count.should == 0
  end
end

describe Answer, '#new_from_params' do
  let(:params) do
    {
     type: @type || 'multiple_choice',
     answer: 'true'
    }
  end
  let(:user) { Fabricate.build(:user, id: 456) }

  subject { Answer.new_from_params(params, user) }

  it 'initializes an instance of specified type when type is a String' do
    @type = 'multiple_choice'
    should be_a MultipleChoiceAnswer
  end

  it 'initializes an instance of specified type when type is a Symbol' do
    @type = :multiple_choice
    should be_a MultipleChoiceAnswer
  end

  it 'returns nil if specified type is unknown' do
    @type = :unknown
    should be_nil
  end

  it "sets answer's user" do
    subject.user.should == user
  end

  it "sets answer's contents" do
    subject.contents.answer.should == 'true'
  end
end
