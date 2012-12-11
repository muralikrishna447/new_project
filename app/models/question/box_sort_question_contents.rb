class BoxSortQuestionContents < OpenStruct
  def update(params)
    params = params[:box_sort_question]
    create_options(params[:options])
    attribute_keys.each do |key|
      self.send("#{key.to_s}=", params.delete(key))
    end
  end

  def to_json(admin)
    self.marshal_dump
  end

  private

  def create_options(options)
    return if options.blank?
    options.map! do |option|
      {
        text: option,
      }
    end
  end

  def unique_id
    SecureRandom.uuid
  end

  def attribute_keys
    [:instructions, :options]
  end
end

