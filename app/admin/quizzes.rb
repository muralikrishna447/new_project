ActiveAdmin.register Quiz do
  menu parent: 'More'

  action_item only: [:show, :edit] do
    link_to_publishable quiz, 'View on Site'
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
        format.html { redirect_to upload_images_admin_quiz_path(@quiz) }
      end
    end
  end

  member_action :manage_questions do
    @quiz = Quiz.find(params[:id])
    @questions = QuestionPresenter.present_collection(@quiz.questions)
  end

  member_action :upload_images do
    @quiz = Quiz.find(params[:id])
    @quiz_images = ImagePresenter.present_collection(@quiz.images)
  end
end

