class QuizzesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :redirect_to_results, only: :show
  before_filter :redirect_to_show, only: :results

  expose(:quiz) { Quiz.find_published(params[:id], params[:token]) }
  expose(:questions) { QuestionPresenter.present_collection(questions_remaining) }
  expose(:quiz_results) { QuizResultsPresenter.new(quiz, current_user).present }

  def results
  end

  def start
    quiz = Quiz.find(params[:id])
    session = QuizSession.find_or_create_by_quiz_id_and_user_id(quiz.id, params[:user_id])
    session.update_attributes(completed: false)
    render json: {'success' => true}, status: :ok
  end

  def finish
    quiz = Quiz.find(params[:id])
    session = QuizSession.find_or_create_by_quiz_id_and_user_id(quiz.id, params[:user_id])
    session.update_attributes(completed: true)
    render json: {'success' => true}, status: :ok
  end

  private

  def redirect_to_results
    redirect_to results_quiz_path(quiz, token: params[:token]) if quiz.completed_by?(current_user)
  end

  def redirect_to_show
    redirect_to quiz_path(quiz, token: params[:token]) unless quiz.completed_by?(current_user)
  end

  def questions_remaining
    @questions_remaining ||= quiz.questions_remaining_for(current_user)
  end
end

