class AnswersController < ApplicationController
  before_filter :authenticate_user!

  def create
    question = Question.find(params[:question_id])
    answer = Answer.new_from_params(params, current_user)
    return head :error if answer.nil?
    question.score(answer)
    render json: {success: true}
  end
end
