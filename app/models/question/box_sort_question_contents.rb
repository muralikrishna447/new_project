class BoxSortQuestionContents < OpenStruct
  def update(params)
    params = params[:box_sort_question]
    create_options if self.options.blank?
    update_options(params[:options])
    self.instructions = params[:instructions]
  end

  def to_json(admin)
    self.marshal_dump
  end

  def correct(answer_data)
    true
  end

  def option(uid)
    options.find { |o| o[:uid] == uid }
  end

  def key_image_display_class(uid)
    index = options.index { |o| o[:uid] == uid }
    return 'ambivalent' if index.nil? || index == 1
    return 'correct' if index == 2
    'incorrect'
  end

  private

  def create_options
    self.options = 3.times.map do
      {uid: unique_id}
    end
  end

  def update_options(options)
    return if options.blank?
    options.each_with_index do |option, index|
      self.options[index][:text] = option
    end
  end

  def unique_id
    SecureRandom.uuid
  end
end


