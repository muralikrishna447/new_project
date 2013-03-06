class QuizResultsPresenter
  def initialize(quiz, user)
    @quiz = quiz
    @user = user
  end

  def present
    results = {
      multiple_choice: [],
      box_sort: [],
      order_sort: []
    }
    @quiz.ordered_questions.each_with_index do |question, index|
      contents = question.contents
      answer = question.answer_for(@user)
      question_type = question.symbolize_question_type
      options = contents.options
      if question_type == :multiple_choice
        mcr = multiple_choice_results(question, answer)
        options.each_with_index do |option, idx|
          option[:status] = :status_none
          if option[:correct]
            option[:status] = :status_right

          # this is heinous - for non t/f multiple choices, answer is recorded as the letter of the option, but options array has the full text
          elsif (mcr[:answer] == option[:answer]) || ('a'..'z').to_a[idx] == mcr[:answer]
            option[:status] = :status_wrong
          end
        end
      end

      results[question_type] << {
        question: contents.question,
        instructions: contents.instructions,
        question_type: question_type,
        order: index + 1,
        options: options,
        correct: answer.correct,
        average_correct: question.average_correct
      }.merge(send("#{question_type}_results", question, answer))
    end
    results
  end

  private

  def order_sort_results(question, answer)
    answer_images = order_sort_correct_answer_images(question, answer)

    {
      best_solution_answer_images: answer_images,
      user_answer_image_ids: answer.contents.answers.join(','),
      best_solution_image_ids: answer.contents.best_solution.join(','),
      solution_score: answer.contents.solution_score
    }
  end

  def order_sort_correct_answer_images(question, answer)
    images = OrderSortImage.find(answer.contents.best_solution).to_a.group_by(&:id)
    sorted = []
    answer.contents.best_solution.each do |id|
      sorted << images[id].first
    end

    ImagePresenter.wrapped_collection(sorted)
  end

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

