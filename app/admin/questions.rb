ActiveAdmin.register Question do
  belongs_to :quiz, shallow: true
  #menu parent: 'More'

  form partial: 'box_sort_form'

  controller do
    def create
      @quiz = Quiz.find(params[:quiz_id])

      type = params[:question_type] || 'multiple_choice'
      question = @quiz.add_question("#{type}_question".to_sym)
      send("respond_to_#{type}_create".to_sym, question)
    end

    def update
      question = Question.find(params[:id])
      question.update_from_params(params)
      send("respond_to_#{question.symbolize_question_type}_update", question)
    end

    def edit
      @question = Question.find(params[:id])
      @question_images = ImagePresenter.present_collection(@question.ordered_images)
      edit!
    end

    private

    def respond_to_box_sort_create(question)
      redirect_to edit_admin_question_path(question)
    end

    def respond_to_multiple_choice_create(question)
      render json: QuestionPresenter.new(question, true).present
    end

    def respond_to_box_sort_update(question)
      redirect_to manage_questions_admin_quiz_path(question.quiz)
    end

    def respond_to_multiple_choice_update(question)
      head :ok
    end
  end

  collection_action :update_order, method: :post do
    @quiz = Quiz.find(params[:quiz_id])
    @quiz.update_question_order(params[:question_order])
    head :ok
  end
end

