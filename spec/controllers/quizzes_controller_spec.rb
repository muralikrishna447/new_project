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
    quiz.should_receive(:questions_remaining_for).with(user).and_return('the questions')
    QuestionPresenter.should_receive(:present_collection) { 'the questions' }
    controller.questions
  end
end
