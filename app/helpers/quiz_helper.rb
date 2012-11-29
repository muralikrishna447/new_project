module QuizHelper
  def show_quizzes?
    Rails.application.config.show_quizzes
  end

  def progress_dial(value, max, label)
    content_tag :div, class: 'dial-wrapper' do
      content = text_field_tag :dial, value, class: 'dial', data: {
        displayinput: false,
        readonly: true,
        thickness: 0.1,
        max: max,
        width: 180,
        height: 180,
        fgcolor: value > 0 ? '#aa4311' : '#EAEAEA',
        bgcolor: value > 0 ? '#EAEAEA' : 'whiteSmoke'
      }
      content += content_tag :span, class: 'dial-text' do
        content_tag(:strong, max) + label
      end
    end
  end
end
