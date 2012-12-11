require 'spec_helper'

describe Admin::QuestionsController do
  login_admin

  let(:quiz) { Fabricate.build(:quiz, id: 123) }

  context 'create' do
    let (:question) { stub('question', id: 456, contents: OpenStruct.new({foo: 'bar'})) }

    before do
      Quiz.stub(:find).with('123') { quiz }
      QuestionPresenter.stub_chain(:new, :present) { {test: 'contents'} }
    end

    context 'when no type specified' do
      it 'adds a multiple choice question to the quiz' do
        quiz.should_receive(:add_question).with(:multiple_choice_question) { question }
        post :create, quiz_id: quiz.id
      end
    end

    context 'when multiple choice type specified' do
      it 'adds a multiple choice question to the quiz' do
        quiz.should_receive(:add_question).with(:multiple_choice_question) { question }
        post :create, quiz_id: quiz.id, question_type: 'multiple_choice'
      end

      it 'returns JSON for new question' do
        post :create, quiz_id: quiz.id, question_type: 'multiple_choice'
        JSON.parse(response.body).should == {'test' => 'contents'}
      end
    end

    context 'when box sort type specified' do
      it 'adds a box sort question to the quiz' do
        quiz.should_receive(:add_question).with(:box_sort_question) { question }
        post :create, quiz_id: quiz.id, question_type: 'box_sort'
      end

      it 'redirects to question edit question action' do
        controller.should_receive(:edit_admin_question_path) { 'path' }
        post :create, quiz_id: quiz.id, question_type: 'box_sort'
        response.should redirect_to 'path'
      end
    end
  end
end

