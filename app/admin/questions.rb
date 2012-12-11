ActiveAdmin.register Question do
  belongs_to :quiz
  menu parent: 'More'

  controller do
    def create
      @quiz = Quiz.find(params[:quiz_id])
      case params[:question_type]
      when "multiple_choice"
        render json: QuestionPresenter.new(@quiz.add_question(:multiple_choice_question), true).present
      when 'box_sort'
        @question = @quiz.add_question(:box_sort_question)
        render 'box_sort_form', layout: 'active_admin'
      else
        render json: QuestionPresenter.new(@quiz.add_question(:multiple_choice_question), true).present
      end
    end

    def update
      @question = Question.find(params[:id])
      @question.update_from_params(params)
      update!
    end
  end

  collection_action :update_order, method: :post do
    @quiz = Quiz.find(params[:quiz_id])
    @quiz.update_question_order(params[:question_order])
    head :ok
  end
end


