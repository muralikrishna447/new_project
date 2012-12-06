require 'spec_helper'

describe QuizzesController, '#show' do
  it 'authenticates action' do
    get :show, id: 1
    response.should redirect_to new_user_session_path
  end

  it 'exposes presented questions' do
    user = stub
    quiz = stub
    controller.stub(:current_user) { user }
    controller.stub(:quiz) { quiz }
    quiz.should_receive(:questions_remaining_for).with(user) { 'the questions' }
    QuestionPresenter.should_receive(:present_collection) { 'the questions' }
    controller.questions
  end

  context 'redirect to results page' do
    let(:questions) { @questions }

    before do
      sign_in Fabricate(:user)
      controller.stub(:quiz) { stub_model(Quiz, id: 123) }
      controller.stub(:questions_remaining) { @questions }
    end

    it 'does not redirect to results page if there are no more questions remaining' do
      @questions = ['the questions']
      get :show, id: 1
      response.should_not redirect_to results_quiz_path(123)
    end

    it 'redirects to results page if there are no more questions remaining' do
      @questions = []
      get :show, id: 1
      response.should redirect_to results_quiz_path(123)
    end
  end
end
