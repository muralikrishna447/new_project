class BoxSortAnswerContents < OpenStruct
  def update(params)
    self.answers = params.delete(:answers)
  end

  def to_json(admin=false)
    self.marshal_dump
  end
end

