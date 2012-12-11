class BoxSortQuestionContents < OpenStruct
  def update(params)
    params.merge!(params[:box_sort_question][:contents])
    add_option_ids(params[:options])
    attribute_keys.each do |key|
      self.send("#{key.to_s}=", params.delete(key))
    end
  end

  def to_json(admin)
    self.marshal_dump
  end

  private

  def add_option_ids(options)
    return if options.blank?
    options.each do |option|
      option.merge!(uid: unique_id) unless option[:uid]
    end
  end

  def unique_id
    SecureRandom.uuid
  end

  def attribute_keys
    [:id, :instructions, :options]
  end
end

