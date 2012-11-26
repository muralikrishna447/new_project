module QuizHelper
  def show_quiz?
    Rails.application.config.show_quizzes && user_signed_in?
  end
end
