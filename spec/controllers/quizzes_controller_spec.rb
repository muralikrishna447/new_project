require 'spec_helper'

describe QuizzesController, '#show' do
  it 'authenticates action' do
    get :show, id: 1
    response.should redirect_to new_user_session_path
  end
end
