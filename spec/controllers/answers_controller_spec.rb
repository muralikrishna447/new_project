require 'spec_helper'

describe AnswersController, "#create" do
  it 'authenticates action' do
    post :create, question_id: 1, id: 1
    response.should redirect_to new_user_session_path
  end

  context 'user is authenticated' do
    let(:params) { {question_id: '1'} }
    let(:user) { Fabricate(:user) }
    let(:question) { stub('question') }
    let(:answer) { stub('answer') }

    before do
      Question.stub(:find).with('1').and_return(question)
      Answer.stub(:new_from_params).and_return(answer)
      question.stub(:score)
      sign_in user
    end

    it 'passes params and user to create Answer' do
      controller.stub(:params) { params }
      Answer.should_receive(:new_from_params).with(params, user).and_return(answer)
      post :create, question_id: 1, id: 1
    end

    it 'scores answer against question' do
      question.should_receive(:score).with(answer)
      post :create, question_id: 1, id: 1
    end

    it 'returns 200 if answer is created and scored' do
      post :create, question_id: 1, id: 1
      response.code.should == '200'
    end

    context 'answer did not get created' do
      before do
        Answer.stub(:new_from_params).and_return(nil)
      end

      it 'returns 500 if answer' do
        post :create, question_id: 1, id: 1
        response.code.should == '500'
      end
    end
  end
end
