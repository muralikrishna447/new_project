module QuizHelper
  def show_quizzes?
    Rails.application.config.show_quizzes
  end

  def progress_dial(value, max)
    text_field_tag :dial, 5, class: 'dial', data: {
      displayinput: false,
      # readonly: true,
      thickness: 0.08,
      max: max,
      fgcolor: '#aa4311',
      bgcolor: '#EAEAEA'
    }
  end
end
