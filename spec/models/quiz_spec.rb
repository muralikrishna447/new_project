require 'spec_helper'

describe Quiz, '#add_multiple_choice_question' do
  let(:quiz) { Fabricate(:quiz) }

  it "creates a new MultipleChoiceQuestion" do
    question = quiz.add_multiple_choice_question
    question.should be_a MultipleChoiceQuestion
    question.should be_persisted
  end

  it "adds question to quiz's questions association" do
    quiz.add_multiple_choice_question
    quiz.questions.should have(1).question
  end
end

describe Quiz, '#question_count' do
  let(:quiz) { Fabricate(:quiz) }

  it 'should return count of questions' do
    quiz.add_multiple_choice_question
    quiz.question_count.should == 1
  end
end

describe Quiz, "update_question_order" do
  let(:quiz) { Fabricate(:quiz) }
  let(:questionA) { Fabricate(:multiple_choice_question) }
  let(:questionB) { Fabricate(:multiple_choice_question) }
  let(:question_ids) { [ questionA.id, questionB.id ].map(&:to_s) }

  before do
    quiz.questions << questionB << questionA
    quiz.update_question_order(question_ids)
  end

  it "updates the order of the questions" do
    quiz.questions.ordered.should == [questionA, questionB]
  end
end

describe Quiz, 'publishing' do
  let!(:public_quiz) { Fabricate(:quiz, id: 1, published: true) }
  let!(:private_quiz) { Fabricate(:quiz, id: 2) }

  its "published flag is set to false by default" do
    private_quiz.should_not be_published
  end

  its "published scope returns published quizzes only" do
    Quiz.published.all.should == [public_quiz]
  end

  context '#find_published' do
    it 'throws not found if quiz does not exist with id' do
      lambda { Quiz.find_published(42) }.should raise_error ActiveRecord::RecordNotFound
    end

    it 'returns quiz if published' do
      Quiz.find_published(1).should == public_quiz
    end

    context 'for private quiz' do
      it 'throws not found' do
        lambda { Quiz.find_published(2) }.should raise_error ActiveRecord::RecordNotFound
      end

      it 'throws not found if token is invalid' do
        PrivateToken.should_receive(:valid?).with('bad_token').and_return(false)
        lambda { Quiz.find_published(2, 'bad_token') }.should raise_error ActiveRecord::RecordNotFound
      end

      it 'returns quiz if token is valid' do
        PrivateToken.should_receive(:valid?).with('good_token').and_return(true)
        Quiz.find_published(2, 'good_token').should == private_quiz
      end
    end
  end
end


