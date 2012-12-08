require 'spec_helper'

describe QuizResultsPresenter do
  let(:quiz) do
    stub(questions: 3.times.map { |i|
      i == 2 ? build_tf_question : build_mc_question
    })
  end
  let(:user) { stub }

  subject { QuizResultsPresenter.new(quiz, user).present }

  it 'presents one entry per quiz question' do
    should have(3).results
  end

  it 'retrieves answer for user for each question' do
    quiz.questions.each do |question|
      question.should_receive(:answer_for).with(user)
    end
    subject
  end

  context 'the presented result' do
    let(:mc_result) { subject.first }
    let(:tf_result) { subject.last }
    let(:question) { quiz.questions.first }
    let(:answer) { question.answer_for(user) }

    it 'includes the question' do
      mc_result[:question].should == question.contents.question
    end

    it 'includes the options' do
      mc_result[:options].should == question.contents.options
    end

    it 'includes correct flag' do
      mc_result[:correct].should == false
    end

    it 'includes the average_correct' do
      mc_result[:average_correct].should == 86
    end

    it "includes the letter for the user's answer if multiple choice" do
      mc_result[:answer].should == 'a'
    end

    it "includes the true/false value for the user's answer if true false" do
      tf_result[:answer].should == 'True'
    end

    it "includes the letter for the correct answer if multiple choice" do
      mc_result[:correct_answer].should == 'a'
    end

    it "includes the true/false value for the correct answer if true false" do
      tf_result[:correct_answer].should == 'True'
    end
  end

  def build_mc_question
    Fabricate.build(:multiple_choice_question).tap do |q|
      q.stub(:answer_for).with(user) { Fabricate.build(:multiple_choice_answer) }
      q.stub(:average_correct) { 86 }
    end
  end

  def build_tf_question
    Fabricate.build(:true_false_question).tap do |q|
      q.stub(:answer_for).with(user) { Fabricate.build(:true_false_answer) }
      q.stub(:average_correct) { 86 }
    end
  end
end
