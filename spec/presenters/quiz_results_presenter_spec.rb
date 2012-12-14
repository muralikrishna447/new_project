require 'spec_helper'

describe QuizResultsPresenter do
  let(:quiz) do
    stub(ordered_questions: [build_mc_question, build_bs_question, build_tf_question])
  end
  let(:user) { stub }

  subject { QuizResultsPresenter.new(quiz, user).present }

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

  context 'multiple choice results' do
    let(:results) { subject[:multiple_choice] }

    it 'presents one entry per multiple choice quiz question' do
      results.should have(2).results
    end

    context 'a multiple choice result' do
      let(:result) { results.first }
      let(:question) { quiz.ordered_questions.first }
      let(:answer) { question.answer_for(user) }

      it 'includes the question order' do
        result[:order].should == 1
      end

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
      let(:result) { results.last }

      it 'includes the question order' do
        result[:order].should == 3
      end

      it "includes the true/false value for the user's answer if true false" do
        result[:answer].should == 'True'
      end

      it "includes the true/false value for the correct answer if true false" do
        result[:correct_answer].should == 'True'
      end
    end
  end

  context 'box sort results' do
    let(:results) { subject[:box_sort] }

    it 'presents one entry per multiple box sort question' do
      results.should have(1).result
    end

    context 'a box sort result' do
      let(:result) { results.first }
      let(:question) { quiz.ordered_questions[1] }

      it 'includes the question order' do
        result[:order].should == 2
      end

      it "includes question instructions" do
        result[:instructions].should == question.contents.instructions
      end

      it "includes question options" do
        result[:options].should == question.contents.options
      end
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
