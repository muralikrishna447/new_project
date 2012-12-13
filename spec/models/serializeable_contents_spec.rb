require 'spec_helper'

describe SerializeableContents, 'initialization' do
  it 'initializes from new with correct content type' do
    MultipleChoiceQuestion.new.contents.should be_a MultipleChoiceQuestionContents
  end

  it 'initializes from create with correct content type' do
    MultipleChoiceQuestion.create.contents.should be_a MultipleChoiceQuestionContents
  end

  it 'does not override value passed in during initialization' do
    MultipleChoiceQuestion.new(contents: 'test').contents.should == 'test'
  end

  it 'does not init contents if question type is baseclass Question' do
    Question.new.contents.should be_blank
  end
end

describe SerializeableContents, '#contents_json' do
  let(:question) { Fabricate.build(:multiple_choice_question) }

  it 'returns contents json' do
    question.contents.should_receive(:to_json).with(false)
    question.contents_json(false)
  end
end
