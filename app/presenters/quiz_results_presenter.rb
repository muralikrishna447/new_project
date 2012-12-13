class QuizResultsPresenter
  def initialize(quiz, user)
    @quiz = quiz
    @user = user
  end

  def present
    @quiz.ordered_questions.map do |question|
      contents = question.contents
      answer = question.answer_for(@user)
      {
        question: contents.question,
        options: contents.options,
        correct: answer.correct,
        answer: contents.option_display(answer.contents.uid),
        correct_answer: contents.correct_option_display,
        average_correct: question.average_correct
      }
    end
  end
end

