require 'spec_helper'

describe Admin::QuestionsController, 'create' do
  login_admin

  let(:quiz) { Fabricate.build(:quiz, id: 123) }
  let(:question) { stub('question', id: 456, images: [], contents: OpenStruct.new({foo: 'bar'})) }

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
      controller.should_receive(:edit_admin_quiz_question_path) { 'path' }
      post :create, quiz_id: quiz.id, question_type: 'box_sort'
      response.should redirect_to 'path'
    end
  end
end



describe Admin::QuestionsController, 'update' do
  login_admin

  let(:quiz) { Fabricate.build(:quiz, id: 123) }
  let(:question) { stub('question', id: 456, contents: OpenStruct.new({foo: 'bar'}), quiz: quiz) }

  before do
    Quiz.stub(:find).with('123') { quiz }
    Question.stub(:find).with('456') { question }
    question.stub(:symbolize_question_type) { :multiple_choice }
    question.stub(:update_from_params)
  end

  it 'updates question' do
    question.should_receive(:update_from_params)
    put :update, id: 456, quiz_id: quiz.id
  end

  it 'returns 200 if type is multiple choice' do
    put :update, id: 456
    response.code.should == '200'
  end

  it 'redirects to question manage action if type is box sort' do
    question.stub(:symbolize_question_type) { :box_sort }
    controller.should_receive(:manage_questions_admin_quiz_path) { 'path' }
    put :update, id: 456
    response.should redirect_to 'path'
  end
end
