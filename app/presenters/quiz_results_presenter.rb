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
        average_correct: question.average_correct
      }.merge(send("#{question.symbolize_question_type}_results", contents, answer))
    end
  end

  private

  def multiple_choice_results(contents, answer)
    {
      answer: contents.option_display(answer.contents.uid),
      correct_answer: contents.correct_option_display,
    }
  end

  def box_sort_results(contents, answer)
    {}
  end
end
