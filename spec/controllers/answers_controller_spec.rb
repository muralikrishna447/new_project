require 'spec_helper'

describe AnswersController, "#create" do
  it 'authenticates action' do
    post :create, question_id: 1, id: 1
    response.should redirect_to new_user_session_path
  end
end
