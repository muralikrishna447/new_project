class MultipleChoiceAnswerContents < OpenStruct
  def update(params)
    self.answer = params.delete(:answer)
    self.uid = params.delete(:uid)
  end

  def to_json(admin=false)
    self.marshal_dump
  end
end
