ActiveAdmin.register Quiz do
  menu parent: 'More'

  action_item only: [:show, :edit] do
    published_model_link quiz, 'View on Site'
  end

  index do
    column 'Link' do |quiz|
      published_model_link(quiz)
    end
    column :id
    column :title
    column :activity
    column :published
    default_actions
  end

  form partial: 'form'

  controller do
    def create
      create! do |format|
        format.html { redirect_to manage_questions_admin_quiz_path(@quiz) }
      end
    end
  end

  member_action :manage_questions do
    @quiz = Quiz.find(params[:id])
    @questions = QuestionPresenter.present_collection(@quiz.questions)
  end
end

