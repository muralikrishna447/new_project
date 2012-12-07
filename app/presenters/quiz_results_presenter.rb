class QuizResultsPresenter
  def initialize(quiz, user)
    @quiz = quiz
    @user = user
  end

  def present
    @quiz.questions.map do |question|
      answer = question.answer_for(@user)
      {
        question: question.contents.question,
        answer: question.contents.option_display(answer.contents.uid),
        correct_answer: question.contents.correct_option_display,
        average_correct: question.average_correct
      }
    end
  end
end
