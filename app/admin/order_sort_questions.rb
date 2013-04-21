ActiveAdmin.register OrderSortQuestion do
  menu false

  form partial: 'edit'

  controller do
    def create
      @quiz = Quiz.find(params[:quiz_id])
      question = @quiz.add_question(:order_sort_question)
      redirect_to edit_admin_order_sort_question_path(question)
    end

    def update
      question = Question.find(params[:id])
      question.update_from_params(params)

      redirect_to manage_questions_admin_quiz_path(question.quiz)
    end

    def edit
      @question = Question.find(params[:id])
      @solutions = @question.contents.solutions.to_json
      @question_images = ImagePresenter.present_collection(@question.images)

      edit!
    end
  end
end
