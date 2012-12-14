class QuizResultsPresenter
  def initialize(quiz, user)
    @quiz = quiz
    @user = user
  end

  def present
    results = {
      multiple_choice: [],
      box_sort: []
    }
    @quiz.ordered_questions.each do |question|
      contents = question.contents
      answer = question.answer_for(@user)
      question_type = question.symbolize_question_type
      results[question_type] << {
        question: contents.question,
        question_type: question_type,
        options: contents.options,
        correct: answer.correct,
        average_correct: question.average_correct
      }.merge(send("#{question_type}_results", contents, answer))
    end
    results
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

