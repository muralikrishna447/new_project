require 'spec_helper'

describe Question, 'contents' do
  it 'initializes from new with correct content type' do
    MultipleChoiceQuestion.new.contents.should be_a MultipleChoiceQuestionContents
  end

  it 'initializes from create with correct content type' do
    MultipleChoiceQuestion.create.contents.should be_a MultipleChoiceQuestionContents
  end

  it 'does not override value passed in during initialization' do
    MultipleChoiceQuestion.new(contents: 'test').contents.should == 'test'
  end
end

describe Question, 'contents_json' do
  let(:question) { Fabricate.build(:multiple_choice_question) }

  it 'returns contents json' do
    question.contents.should_receive(:to_json).with(false)
    question.contents_json(false)
  end
end

describe Question, '#score_answer' do
  let(:question) { Fabricate.build(:multiple_choice_question, id: 123) }
  let(:user) { Fabricate.build(:user, id: 456) }

  let(:answer_model) { Fabricate.build(:answer) }
  let(:answer_data) { {answer: 'test'} }

  before do
    question.contents.stub(:correct)
  end

  subject { question.score_answer(answer_data, user) }

  it 'returns the created answer' do
    should be_a Answer
  end

  it "sets answer's user" do
    subject.user.should == user
  end

  it "sets answer's contents" do
    subject.contents.should == answer_data
  end

  it 'corrects the answer' do
    question.contents.should_receive(:correct).with(answer_data)
    subject
  end

  it "sets answer's correct value to true if correct call returns true" do
    question.contents.stub(:correct).and_return(true)
    subject.correct.should be_true
  end

  it "sets answer's correct value to false if correct call returns false" do
    question.contents.stub(:correct).and_return(false)
    subject.correct.should be_false
  end

  it 'associates answer with question' do
    subject.question_id.should == question.id
  end
end

describe Question, '#answer_count' do
end

describe Question, '#incorrect_answer_count' do
end
