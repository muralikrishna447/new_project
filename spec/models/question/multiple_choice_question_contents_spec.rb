require 'spec_helper'

describe MultipleChoiceQuestionContents, '#update' do
  let(:multi_choice_contents) { Fabricate.build(:multiple_choice_question_contents) }
  let(:content_attributes) { { question: 'question stuff', instructions: 'instruction stuff',
                       options: [{title: 'option 1'}] } }
  let(:params) { {foo: 'bar'}.merge(content_attributes) }

  it "updates values defined in the keys" do
    multi_choice_contents.update(params)
    multi_choice_contents.marshal_dump.should == content_attributes
  end
end

describe MultipleChoiceQuestionContents, '#to_json' do
  let(:admin) { false }
  let(:contents) { Fabricate.build(:multiple_choice_question_contents) }

  subject { contents.to_json(admin) }

  its(:keys) { should =~ [:question, :options] }

  it 'excludes correct flag from options' do
    options_correct?.should_not be
  end

  context 'admin flag is true' do
    let(:admin) { true }
    it 'excludes correct flag from options' do
      options_correct?.should be
    end
  end

  def options_correct?
    subject[:options].any?{|o| o[:correct]}
  end
end

describe MultipleChoiceQuestionContents, '#correct' do
  let(:contents) { Fabricate.build(:multiple_choice_question_contents) }
  let(:answer) { Fabricate.build(:multiple_choice_answer_contents, answer: 'Answer Correct') }

  it 'returns true if answer matches correct option' do
    contents.correct(answer).should be_true
  end

  it 'returns false if answer does not match correct option' do
    answer.answer = 'Answer Incorrect'
    contents.correct(answer).should be_false
  end

  it 'returns false if answer cannot be found in options' do
    answer.answer = 'invalid answer'
    contents.correct(answer).should be_false
    answer.delete_field(:answer)
    contents.correct(answer).should be_false
  end
end
