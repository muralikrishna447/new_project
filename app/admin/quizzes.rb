ActiveAdmin.register Quiz do
  menu priority: 4

  action_item only: [:show, :edit] do
    link_to_publishable quiz, 'View on Site'
  end

  action_item only: [:index] do
    link_to "Download Report CSV", report_admin_quizzes_path
  end

  index do
    column 'Link' do |quiz|
      link_to_publishable(quiz)
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

  collection_action :report do
    render csv: Quiz.all, style: :report
  end

  member_action :manage_questions do
    @quiz = Quiz.find(params[:id])
    @questions = QuestionPresenter.present_collection(@quiz.ordered_questions, true)
  end
end

