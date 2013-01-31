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

  # TODO[dbalatero]: implement this.
  def correct(answer_data)
    true
  end

private

  # TODO[dbalatero]: replace this when we get a real UI.
  def parse_text_solutions(solutions)
    return [] if solutions.blank?

    solutions.split('|').map do |solution|
      { 'order_sort_image_ids' => solution.split(',').map(&:to_i) }
    end
  end
end
