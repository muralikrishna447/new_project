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
    @quiz.ordered_questions.each_with_index do |question, index|
      contents = question.contents
      answer = question.answer_for(@user)
      question_type = question.symbolize_question_type
      results[question_type] << {
        question: contents.question,
        instructions: contents.instructions,
        question_type: question_type,
        order: index+1,
        options: contents.options,
        correct: answer.correct,
        average_correct: question.average_correct
      }.merge(send("#{question_type}_results", question, answer))
    end
    results
  end

  private

  def multiple_choice_results(question, answer)
    {
      answer: question.contents.option_display(answer.contents.uid),
      correct_answer: question.contents.correct_option_display,
    }
  end

  def box_sort_results(question, answer)
    answers = answer.contents.answers
    key_images = ImagePresenter.wrapped_collection(question.key_images).map do |image|
      answer_for_image = answers.find { |a| a[:id] == image[:id] }
      image[:display_class] = question.contents.key_image_display_class(answer_for_image[:optionUid])
      image
    end
    {
      key_images: key_images
    }
  end
end

