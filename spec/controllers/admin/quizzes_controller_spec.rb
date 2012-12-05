require 'spec_helper'

describe Admin::QuizzesController do
  login_admin

  it 'redirects to add questions flow on create' do
    post :create
    response.should redirect_to(upload_images_admin_quiz_path(Quiz.first))
  end

  context 'manage_questions' do
    let(:quiz) { Fabricate.build(:quiz, id: 123) }
    let(:questions_presenter) { stub }

    before do
      Quiz.should_receive(:find).with('123') { quiz }
      QuestionPresenter.stub(:present_collection)
    end

    it 'assigns quiz model' do
      get :manage_questions, id: quiz.id
      assigns[:quiz].should == quiz
    end

    it 'assigns presented questions' do
      QuestionPresenter.should_receive(:present_collection) { 'presented' }
      get :manage_questions, id: quiz.id
      assigns[:questions].should == 'presented'
    end
  end

end
