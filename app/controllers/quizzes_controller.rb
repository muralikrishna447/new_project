class QuizzesController < ApplicationController
  before_filter :authenticate_user!

  expose(:quiz) { Quiz.find_published(params[:id], params[:token]) }
end
