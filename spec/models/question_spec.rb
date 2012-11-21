require 'spec_helper'

describe Question, 'contents' do
  let(:test_contents) { MultipleChoiceQuestionContents.new({test: 'stuff'}) }
  let(:question) { Fabricate.build(:multiple_choice_question) }

  it 'deserializes contents into specific type object' do
    question.contents = test_contents
    question.contents.should be_a MultipleChoiceQuestionContents
    question.contents.test.should == 'stuff'
  end

  it 'serializes contents from specific type object' do
    question.contents = test_contents
    question.save
    question.contents.should == test_contents
  end

end
