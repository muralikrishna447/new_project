require 'spec_helper'

describe QuizzesController, '#show' do
  it 'authenticates action' do
    get :show, id: 1
    response.should redirect_to new_user_session_path
  end

  it 'exposes presented questions' do
    controller.stub(:quiz) { stub('quiz', ordered_questions: 'the questions') }
    QuestionPresenter.should_receive(:present_collection) { 'the questions' }
    controller.questions
  end
end
