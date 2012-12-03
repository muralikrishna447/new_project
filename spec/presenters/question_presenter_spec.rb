require 'spec_helper'

describe QuestionPresenter, "#present" do
  let(:question) { stub('question', id: 123, contents_json: {key: 'val'}) }
  let(:question_presenter) { QuestionPresenter.new(question) }

  subject { question_presenter.attributes }

  it "serializes id" do
    subject[:id].should == 123
  end

  it "merges model's contents_json" do
    subject[:key].should == 'val'
  end
end
