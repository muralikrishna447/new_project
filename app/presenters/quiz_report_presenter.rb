class QuizReportPresenter
  def initialize(quiz)
    @quiz = quiz
  end

  def present
    CSV.generate do |csv|
      add_summary_statistics(csv)
      csv << []

      questions_header = ['User']
      correct_answers = ['Correct Answers']
      user_answers = {}

      @quiz.ordered_questions.each_with_index do |question, index|
        questions_header += send("#{question.symbolize_question_type}_header", question, index)
        correct_answers += send("#{question.symbolize_question_type}_answers", question)
        send("#{question.symbolize_question_type}_user_answers", question, user_answers)
      end

      csv << questions_header
      csv << correct_answers
      user_answers.each do |email, answers|
        csv << [email] + answers
      end
    end
  end

  private

  def add_summary_statistics(csv)
    csv << [@quiz.title]
    csv << ["Users Started", "Users Completed", "Questions"]
    csv << [@quiz.started_count, @quiz.completed_count, @quiz.question_count]
  end

  def multiple_choice_header(question, question_index)
    ["Q#{question_index+1} (MultChoice)"]
  end

  def multiple_choice_answers(question)
    [question.contents.correct_option_display]
  end

  def multiple_choice_user_answers(question, user_answers)
    question.answers.each do |answer|
      email = answer.user.email
      user_answers[email] ||= []
      user_answers[email] << question.contents.option_display(answer.contents.uid)
    end
  end

  def box_sort_header(question, question_index)
    header = []
    question.images.each_with_index do |image, image_index|
      header << "Q#{question_index+1}I#{image_index+1} (ImageSort)"
    end
    header
  end

  def box_sort_answers(question)
    answers = []
    question.images.each_with_index do |image, image_index|
      answers << image.key_image?
    end
    answers
  end

  def box_sort_user_answers(question, user_answers)
    question.answers.each do |answer|
      email = answer.user.email
      user_answers[email] ||= []
      question.images.each do |image|
        user_selection = answer.contents.answers.find {|a| a['id'] == image.id}
        option = question.contents.option(user_selection['optionUid'])
        user_answers[email] << (option && option[:text])
      end
    end
  end
end

