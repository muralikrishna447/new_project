require 'spec_helper'

include Devise::TestHelpers

describe Admin::QuizzesController do
  login_admin

  it 'redirects to add questions flow on create' do
    post :create
    response.should redirect_to(questions_admin_quiz_path(1))
  end
end
