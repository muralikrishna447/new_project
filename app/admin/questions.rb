ActiveAdmin.register Question do
  belongs_to :quiz
  menu parent: 'More'

  controller do
    def create
      @quiz = Quiz.find(params[:quiz_id])
      render json: QuestionPresenter.new(@quiz.add_multiple_choice_question).present
    end

    def update
      @question = Question.find(params[:id])
      @question.update_contents(params)
      update!
    end
  end
end


