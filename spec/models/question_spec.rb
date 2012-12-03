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
    question.contents.should_receive(:to_json)
    question.contents_json
  end
end
