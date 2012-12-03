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
  let(:contents) { Fabricate.build(:multiple_choice_question_contents) }

  subject { contents.to_json }

  its(:keys) { should =~ [:question, :options] }
end

