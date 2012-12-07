class QuizzesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :redirect_to_results, only: :show

  expose(:quiz) { Quiz.find_published(params[:id], params[:token]) }
  expose(:questions) { QuestionPresenter.present_collection(questions_remaining) }
  expose(:quiz_results) { QuizResultsPresenter.new(quiz, current_user).present }

  def results
  end

  private

  def redirect_to_results
    redirect_to results_quiz_path(quiz) if quiz.completed_by?(current_user)
  end

  def questions_remaining
    @questions_remaining ||= quiz.questions_remaining_for(current_user)
  end
end
