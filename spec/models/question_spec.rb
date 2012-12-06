require 'spec_helper'

describe Question, '#correct' do
  let(:question) { Fabricate.build(:multiple_choice_question, id: 123) }
  let(:answer) { stub('answer', contents: 'contents') }

  it 'corrects answer against question contents' do
    question.contents.should_receive(:correct).with('contents')
    question.correct(answer)
  end
end

describe Question, '#score' do
  let(:question) { Fabricate.build(:multiple_choice_question, id: 123) }
  let(:user) { Fabricate.build(:user, id: 123) }

  let(:answer) { Fabricate.build(:multiple_choice_answer, user: user) }

  before do
    question.contents.stub(:correct)
  end

  subject { question.score(answer) }

  it 'corrects the answer' do
    question.should_receive(:correct).with(answer)
    subject
  end

  it "sets answer's correct value to true if correct call returns true" do
    question.stub(:correct).and_return(true)
    subject
    answer.correct.should be_true
  end

  it "sets answer's correct value to false if correct call returns false" do
    question.stub(:correct).and_return(false)
    subject
    answer.correct.should be_false
  end

  it 'associates answer with question' do
    subject.question_id.should == question.id
  end
end

describe Question, '#answer_count' do
  let(:question) { Fabricate(:multiple_choice_question) }
  before { question.answers << Fabricate(:multiple_choice_answer, question: question) }

  it 'increments count when new answer is added' do
    question.answer_count.should == 1
  end
end

describe Question, '#update_image' do
  let(:question) { Fabricate.build(:multiple_choice_question) }
  let(:image_params) { { url: 'www.foo.bar', filename: 'some file name', key: '123', size: 5005 } }

  subject { question.update_image(image_params) }

  it "creates an image if none exist" do
    subject.filename.should == 'some file name'
    subject.url.should == 'www.foo.bar'
  end

  context "with an existing image" do
    let(:image) { Fabricate.build(:image) }

    before do
      question.image = image
    end

    it "updates the image" do
      subject.filename.should == 'some file name'
      subject.url.should == 'www.foo.bar'
    end
  end
end
