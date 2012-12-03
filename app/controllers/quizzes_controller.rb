class QuizzesController < ApplicationController
  before_filter :authenticate_user!

  expose(:quiz) { Quiz.find_published(params[:id], params[:token]) }
  expose(:questions) { QuestionPresenter.present_collection(quiz.questions) }
end
