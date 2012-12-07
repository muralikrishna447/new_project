module QuizHelper
  def show_quizzes?
    Rails.application.config.show_quizzes
  end

  def estimated_mins(question_count)
    [estimated_secs(question_count) / 60, 1].max
  end

  def estimated_secs(question_count)
    question_count * 20
  end

  def progress_dial(value, max, opts={}, &block)
    opts = {
      label: '',
      size: 'normal',
      display_value: false
    }.merge(opts)
    content_tag :div, class: "dial-wrapper #{opts[:size]}", data: {behavior: 'progress-dial'} do
      content = text_field_tag :dial, value, data: {
        displayinput: false,
        readonly: true,
        thickness: 0.1,
        max: max,
        fgcolor: value > 0 ? '#aa4311' : '#EAEAEA',
        bgcolor: value > 0 ? '#EAEAEA' : 'whiteSmoke'
      }
      content += content_tag :span, class: 'dial-text' do
        display_value = opts[:display_value] || max
        content_tag(:strong, display_value) + opts[:label]
      end
      if block_given?
        content += content_tag(:div, class: 'dial-caption', &block)
      end
      content
    end
  end

  def question_count_stats(quiz)
    [quiz.questions_answered_by_count(current_user),
     quiz.question_count]
  end

  def question_time_stats(quiz)
    [estimated_secs(quiz.questions_answered_by_count(current_user)),
     estimated_secs(quiz.question_count)]
  end
end
