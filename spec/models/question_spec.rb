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
