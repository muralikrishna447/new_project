require 'spec_helper'

include Devise::TestHelpers

describe Admin::QuizzesController do
  login_admin

  it 'redirects to add questions flow on create' do
    post :create
    response.should redirect_to(questions_admin_quiz_path(1))
  end

  context 'questions action' do
    let(:quiz) { Fabricate.build(:quiz, id: 123) }
    let(:questions_presenter) { stub }

    before do
      Quiz.should_receive(:find).with('123') { quiz }
      QuestionPresenter.stub(:present_collection)
      quiz.stub(:questions) { ['question'] }
    end

    it 'assigns quiz model' do
      get :questions, id: quiz.id
      assigns[:quiz].should == quiz
    end

    it 'assigns presented questions' do
      QuestionPresenter.should_receive(:present_collection).with(['question']) { 'presented' }
      get :questions, id: quiz.id
      assigns[:questions].should == 'presented'
    end
  end
end
