require 'spec_helper'

describe QuizResultsPresenter do
  let(:quiz) do
    stub(ordered_questions: [build_mc_question, build_bs_question, build_tf_question])
  end
  let(:user) { stub }

  subject { QuizResultsPresenter.new(quiz, user).present }

  it 'presents one entry per quiz question' do
    should have(3).results
  end

  it 'uses ordered questions' do
    quiz.should_receive(:ordered_questions)
    subject
  end

  it 'retrieves answer for user for each question' do
    quiz.ordered_questions.each do |question|
      question.should_receive(:answer_for).with(user)
    end
    subject
  end

  context 'a multiple choice result' do
    let(:result) { subject.first }
    let(:question) { quiz.ordered_questions.first }
    let(:answer) { question.answer_for(user) }

    it 'includes the question_type' do
      result[:question_type].should == :multiple_choice
    end

    it 'includes the question' do
      result[:question].should == question.contents.question
    end

    it 'includes the options' do
      result[:options].should == question.contents.options
    end

    it 'includes correct flag' do
      result[:correct].should == false
    end

    it 'includes the average_correct' do
      result[:average_correct].should == 86
    end

    it "includes the letter for the user's answer if multiple choice" do
      result[:answer].should == 'a'
    end

    it "includes the letter for the correct answer if multiple choice" do
      result[:correct_answer].should == 'a'
    end
  end

  context 'a true/false result' do
    let(:result) { subject.last }

    it "includes the true/false value for the user's answer if true false" do
      result[:answer].should == 'True'
    end

    it "includes the true/false value for the correct answer if true false" do
      result[:correct_answer].should == 'True'
    end
  end

  context 'a box sort result' do
    let(:result) { subject[1] }
    let(:question) { quiz.ordered_questions[1] }

    it "includes question options" do
      result[:options].should == question.contents.options
    end
  end

  def build_mc_question
    Fabricate.build(:multiple_choice_question).tap do |q|
      q.stub(:answer_for).with(user) { Fabricate.build(:multiple_choice_answer, question: q) }
      q.stub(:average_correct) { 86 }
    end
  end

  def build_tf_question
    Fabricate.build(:true_false_question).tap do |q|
      q.stub(:answer_for).with(user) { Fabricate.build(:true_false_answer, question: q) }
      q.stub(:average_correct) { 86 }
    end
  end

  def build_bs_question
    Fabricate.build(:box_sort_question).tap do |q|
      q.stub(:answer_for).with(user) { Fabricate.build(:box_sort_answer, question: q) }
    end
  end
end
