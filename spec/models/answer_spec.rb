describe Answer, '#update_question_statistics' do
  let(:question) { Fabricate(:multiple_choice_question, correct_answer_count: 1, incorrect_answer_count: 1) }
  let(:answer) { Fabricate.build(:multiple_choice_answer, question: question, correct: @correct) }

  it "increments question's correct answer count if answer is correct" do
    @correct = true
    answer.send(:update_question_statistics)
    question.correct_answer_count.should == 2
    question.incorrect_answer_count.should == 1
  end

  it "increments question's correct answer count if answer is incorrect" do
    @correct = false
    answer.send(:update_question_statistics)
    question.correct_answer_count.should == 1
    question.incorrect_answer_count.should == 2
  end
end

describe Answer, '#new_of_type' do
  it 'initializes an instance of specified type when type is a String' do
    Answer.new_of_type('multiple_choice').should be_a MultipleChoiceAnswer
  end

  it 'initializes an instance of specified type when type is a Symbol' do
    Answer.new_of_type(:multiple_choice).should be_a MultipleChoiceAnswer
  end

  it 'returns nil if specified type is unknown' do
    Answer.new_of_type(:unknown).should be_nil
  end
end
