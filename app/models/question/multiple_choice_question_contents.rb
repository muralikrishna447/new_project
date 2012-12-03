class MultipleChoiceQuestionContents < OpenStruct

  def update(params)
    attribute_keys.each do |key|
      self.send("#{key.to_s}=", params.delete(key))
    end
  end

  def to_json
    self.marshal_dump
  end

  private

  def attribute_keys
    [:question, :instructions, :options]
  end
end

