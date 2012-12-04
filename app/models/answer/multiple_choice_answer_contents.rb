class MultipleChoiceAnswerContents < OpenStruct
  def update(params)
    self.answer = params.delete(:answer)
  end

  def to_json(admin=false)
    self.marshal_dump
  end
end
