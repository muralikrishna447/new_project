require 'spec_helper'

describe Admin::QuestionsController do
  login_admin

  let(:quiz) { Fabricate.build(:quiz, id: 123) }

  context 'index' do
    let (:question) { stub('question', id: 456, question_order: 5, contents: OpenStruct.new({foo: 'bar'})) }

    it 'returns JSON for new question' do
      Quiz.stub(:find).with('123') { quiz }
      quiz.should_receive(:add_multiple_choice_question) { question }

      post :create, quiz_id: quiz.id
      JSON.parse(response.body).should == {'id' => 456, 'foo' => 'bar', 'question_order' => 5}
    end
  end
end

