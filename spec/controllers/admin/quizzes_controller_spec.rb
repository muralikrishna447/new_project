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

    before do
      Quiz.should_receive(:find).with('123') { quiz }
      quiz.stub(:questions) { ['q1'] }
      get :questions, id: quiz.id
    end

    it 'assigns quiz model' do
      assigns[:quiz].should == quiz
    end

    it 'assigns questions collection' do
      assigns[:questions].should == ['q1']
    end
  end
end
