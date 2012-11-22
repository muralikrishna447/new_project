ActiveAdmin.register Quiz do
  menu parent: 'More'

  index do
    column :id
    column :title
    column :activity
    default_actions
  end

  form partial: 'form'

  controller do
    def create
      create! do |format|
        format.html { redirect_to questions_admin_quiz_path(@quiz) }
      end
    end
  end

  member_action :questions do
    @quiz = Quiz.find(params[:id])
    @questions = QuestionPresenter.present_collection(@quiz.questions)
  end
end

