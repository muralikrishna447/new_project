module QuizHelper
  def show_quizzes?
    Rails.application.config.show_quizzes
  end

  def estimated_time(question_count)
    question_count * 20 / 60
  end

  def progress_dial(value, max, label, size=nil)
    content_tag :div, class: "dial-wrapper #{size}", data: {behavior: 'progress-dial'} do
      content = text_field_tag :dial, value, data: {
        displayinput: false,
        readonly: true,
        thickness: 0.1,
        max: max,
        fgcolor: value > 0 ? '#aa4311' : '#EAEAEA',
        bgcolor: value > 0 ? '#EAEAEA' : 'whiteSmoke'
      }
      content += content_tag :span, class: 'dial-text' do
        content_tag(:strong, max) + label
      end
    end
  end
end
