class MultipleChoiceQuestionContents < OpenStruct

  def update(params)
    add_option_ids(params[:options])
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

  def correct(answer_data)
    options.any? do|option|
      option[:uid] == answer_data.uid && option[:correct]
    end
  end

  private

  def add_option_ids(options)
    return unless options.present?
    options.each do |option|
      option.merge!(uid: unique_id) unless option[:uid]
    end
  end

  def unique_id
    SecureRandom.uuid
  end

  def attribute_keys
    [:id, :question, :instructions, :options]
  end
end

