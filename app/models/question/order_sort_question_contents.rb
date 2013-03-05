require 'delve/order_sort_question/scorer'

class OrderSortQuestionContents < OpenStruct
  # Schema:
  #   {
  #     question: "How do you cook a steak?",
  #     instructions: "Please arrange the images in the correct order.",
  #     solutions: [
  #       {
  #         order_sort_image_ids: [1, 2, 3, 4]
  #       },
  #       {
  #         order_sort_image_ids: [2, 1, 3, 4]
  #       }
  #     ]
  #   }

  def update(params)
    q = params['order_sort_question']

    self.question = q['question']
    self.instructions = q['instructions']
    self.solutions = parse_text_solutions(q['solutions'])
  end

  def to_json(admin)
    self.marshal_dump
  end

  # Check a given answer against the set of solutions.
  #
  # `answer_data` - OrderSortAnswerContents
  def correct(answer_data)
    scorers.any? { |scorer| scorer.matches?(answer_ids(answer_data)) }
  end

  # Returns the max score the user received.
  def solution_score(answer_data)
    scorers.map { |scorer| scorer.solution_score(answer_ids(answer_data)) }.max
  end

private

  def answer_ids(answer_data)
    answer_data.answers.map(&:to_i)
  end

  # For each available solution, return a scorer we can use to check answers.
  def scorers
    solutions.map { |solution| scorer_for_solution(solution) }
  end

  # Build a scorer for a given solution from the `self.solutions` array.
  def scorer_for_solution(solution)
    Delve::OrderSortQuestion::Scorer.new(solution['order_sort_image_ids'])
  end

  # TODO[dbalatero]: replace this when we get a real UI.
  def parse_text_solutions(solutions)
    return [] if solutions.blank?

    solutions.split('|').map do |solution|
      { 'order_sort_image_ids' => solution.split(',').map(&:to_i) }
    end
  end
end
