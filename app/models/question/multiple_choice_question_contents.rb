class MultipleChoiceQuestionContents < OpenStruct

  def update(params)
    attribute_keys.each do |key|
      self.send("#{key.to_s}=", params.delete(key))
    end
  end

  def to_json(admin)
    json = self.marshal_dump
    json[:options].each do |option|
      option.delete(:correct) unless admin
    end if json[:options]
    json
  end

  private

  def attribute_keys
    [:question, :instructions, :options]
  end
end

