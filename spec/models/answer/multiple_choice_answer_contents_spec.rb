require 'spec_helper'

describe MultipleChoiceAnswerContents, '#update' do
  let(:contents) { Fabricate.build(:multiple_choice_answer_contents) }

  it 'saves answer key' do
    contents.update(answer: false)
    contents.answer.should be_false
  end

  it 'saves answer uid' do
    contents.update(uid: 'ABC')
    contents.uid.should == 'ABC'
  end

  it 'does not save any other keys' do
    contents.update(bad_key: 'bad')
    contents.bad_key.should be_nil
  end
end

describe MultipleChoiceAnswerContents, '#to_json' do
  let(:contents) { Fabricate.build(:multiple_choice_answer_contents) }

  it 'uses marshal_dump' do
    contents.should_receive(:marshal_dump)
    contents.to_json
  end
end
