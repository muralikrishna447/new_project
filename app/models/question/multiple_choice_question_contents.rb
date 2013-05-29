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

  def correct_option_display
    correct_option = options.find {|option| option[:correct]}
    return if correct_option.nil?
    option_display(correct_option[:uid])
  end

  def option_display(uid)
    index = options.index { |o| o[:uid] == uid }
    return nil if index.nil?
    option = options[index]
    return option[:answer].titleize if is_true_false?(option)
    ('a'..'z').to_a[index]
  end

  private

  def is_true_false?(option)
    ['true', 'false'].include? option[:answer].downcase
  end

  def index_to_letter(index)
    ('a'..'z').to_a[index]
  end

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
    [:id, :question, :instructions, :options, :explanation]
  end
end

