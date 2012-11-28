module QuizHelper
  def show_quizzes?
    Rails.application.config.show_quizzes
  end

  def progress_dial(value, max)
    content_tag :div, class: 'dial-wrapper' do
      text_field_tag :dial, value, class: 'dial', data: {
        displayinput: false,
        readonly: true,
        thickness: 0.08,
        max: max,
        fgcolor: '#aa4311',
        bgcolor: '#EAEAEA'
      }
    end
  end
end
