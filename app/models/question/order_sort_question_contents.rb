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
    self.solutions = q['solutions']
  end

  def to_json(admin)
    self.marshal_dump
  end

  # TODO[dbalatero]: implement this.
  def correct(answer_data)
    true
  end
end
