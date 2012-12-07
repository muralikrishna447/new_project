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
    let(:user) { Fabricate(:user) }
    let(:quiz) { stub_model(Quiz, id: 123) }

    before do
      sign_in user
      controller.stub(:quiz) { quiz }
    end

    it 'does not redirect to results page if quiz has not been completed' do
      quiz.stub(:completed_by?).with(user).and_return(false)
      get :show, id: 1
      response.should_not redirect_to results_quiz_path(123)
    end

    it 'redirects to results page if quiz has been completed' do
      quiz.stub(:completed_by?).with(user).and_return(true)
      get :show, id: 1
      response.should redirect_to results_quiz_path(123)
    end
  end
end

describe QuizzesController, 'quiz results exposure' do
  it 'should present quiz results for user' do
    user = stub
    quiz = stub
    presenter = stub
    controller.stub(:current_user) { user }
    controller.stub(:quiz) { quiz }
    QuizResultsPresenter.should_receive(:new).with(quiz, user) { presenter }
    presenter.should_receive(:present)
    controller.quiz_results
  end
end
