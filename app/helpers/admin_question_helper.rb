module AdminQuestionHelper
  # TODO[dbalatero]: remove this after real UI is implemented.
  def solution_image_ids(question)
    return if question.solutions.blank?

    solutions.map { |solution|
      solution['order_sort_image_ids'].join(',')
    }.join('|')
  end
end
