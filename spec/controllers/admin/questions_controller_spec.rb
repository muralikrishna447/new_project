require 'spec_helper'

describe Admin::QuestionsController do
  login_admin

  let(:quiz) { Fabricate.build(:quiz, id: 123) }

  context 'index' do
    it 'returns JSON for new question' do
      Quiz.stub(:find).with('123') { quiz }
      quiz.should_receive(:add_multiple_choice_question) { stub('question', id: 456, title: 'question title') }

      post :create, quiz_id: quiz.id
      JSON.parse(response.body).should == {'id' => 456, 'title' => 'question title'}
    end
  end
end

