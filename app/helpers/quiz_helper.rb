module QuizHelper
  def show_quizzes?
    Rails.application.config.show_quizzes && user_signed_in?
  end
end
