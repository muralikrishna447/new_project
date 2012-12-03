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

    it 'adds a question to the quiz' do
      quiz.should_receive(:add_multiple_choice_question) { question }
      post :create, quiz_id: quiz.id
    end

    it 'returns JSON for new question' do
      post :create, quiz_id: quiz.id
      JSON.parse(response.body).should == {'test' => 'contents'}
    end
  end
end

