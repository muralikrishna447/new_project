class BoxSortAnswerContents < OpenStruct
  def update(params)
  end

  def to_json(admin=false)
    self.marshal_dump
  end
end

