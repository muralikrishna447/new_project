class BoxSortQuestionContents < OpenStruct

  def to_json(admin)
    self.marshal_dump
  end
end

