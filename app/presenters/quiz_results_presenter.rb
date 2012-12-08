class QuizResultsPresenter
  def initialize(quiz, user)
    @quiz = quiz
    @user = user
  end

  def present
    @quiz.questions.map do |question|
      contents = question.contents
      answer = question.answer_for(@user)
      {
        question: contents.question,
        answer: contents.option_display(answer.contents.uid),
        correct_answer: contents.correct_option_display,
        average_correct: question.average_correct
      }
    end
  end
end
