require 'spec_helper'

describe QuestionPresenter, "#present" do
  let(:admin) { false }
  let(:question) { stub('question', id: 123, contents_json: {key: 'val'}) }
  let(:question_presenter) { QuestionPresenter.new(question, admin) }

  subject { question_presenter.attributes }

  it "serializes id" do
    subject[:id].should == 123
  end

  it "merges model's contents_json" do
    subject[:key].should == 'val'
  end

  it 'passes false admin flag to contents_json' do
    question.should_receive(:contents_json).with(false)
    subject
  end

  context 'admin flag is true' do
    let(:admin) { true }
    it 'passes true admin flag to contents_json' do
      question.should_receive(:contents_json).with(true)
      subject
    end
  end
end
