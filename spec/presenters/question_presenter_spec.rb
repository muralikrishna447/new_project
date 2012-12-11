require 'spec_helper'

describe QuestionPresenter, "#present" do
  let(:admin) { false }
  let(:question) { stub('question', id: 123, contents_json: {key: 'val'}, image: nil, symbolize_question_type: :important) }
  let(:question_presenter) { QuestionPresenter.new(question, admin) }

  subject { question_presenter.attributes }

  context "without an image" do
    it "serializes id" do
      subject[:id].should == 123
    end

    it "serializes question type" do
      subject[:question_type].should == :important
    end

    it "merges model's contents_json" do
      subject[:key].should == 'val'
    end

    it 'passes false admin flag to contents_json' do
      question.should_receive(:contents_json).with(false)
      subject
    end

    it "doesn't include the image key" do
      subject.keys.should_not include :image
    end
  end

  context 'admin flag is true' do
    let(:admin) { true }
    it 'passes true admin flag to contents_json' do
      question.should_receive(:contents_json).with(true)
      subject
    end
  end

  context "with an image" do
    before do
      ImagePresenter.stub_chain(:new, :wrapped_attributes).and_return('image attributes')
      question.stub(:image).and_return(Fabricate.build(:image))
    end

    it "includes the presented image in the attributes" do
      subject[:image].should == 'image attributes'
    end

  end
end
