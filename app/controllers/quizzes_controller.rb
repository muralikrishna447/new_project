class QuizzesController < ApplicationController
  before_filter :authenticate_user!

  expose(:quiz)
  expose(:questions) { QuestionPresenter.present_collection(quiz.questions) }
end
