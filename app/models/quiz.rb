class Quiz < ActiveRecord::Base
  extend FriendlyId
  include PublishableModel
  include Imageable

  friendly_id :title, use: :slugged

  belongs_to :activity

  has_many :questions

  has_many :quiz_sessions, dependent: :destroy, inverse_of: :quiz

  attr_accessible :title, :activity_id, :start_copy, :end_copy, :image_attributes
  accepts_nested_attributes_for :image, allow_destroy: true

  def add_question(question_type)
    question = question_class_from_type(question_type).create
    questions << question
    question.update_order(:last)
    question
  end

  def question_count
    questions.count
  end

  def ordered_questions
    questions.ordered
  end

  def update_question_order(question_ids)
    question_ids.each do |question_id|
      questions.find(question_id).update_order(:last)
    end
  end

  def questions_answered_by(user)
    ordered_questions.joins(:answers).where(answers: {user_id: user.id})
  end

  def questions_remaining_for(user)
    ordered_questions - questions_answered_by(user)
  end

  def questions_answered_by_count(user)
    questions_answered_by(user).count
  end

  def questions_remaining_for_count(user)
    questions_remaining_for(user).count
  end

  def started_by?(user)
    questions_answered_by_count(user) > 0
  end

  def completed_by?(user)
    question_count > 0 && questions_remaining_for_count(user) == 0
  end

  def started_count
    ordered_questions.first.answer_count
  end

  def completed_count
    ordered_questions.last.answer_count
  end

  def has_image?
    image? && image.url?
  end

  comma :report do
    title
    started_count "Users Started"
    completed_count "Users Completed"
    question_count "Questions"
  end

  def full_report
    def box_sort_header_and_answers(question, question_index)
      header = []
      answers = []
      question.images.each_with_index do |image, image_index|
        header << "Q#{question_index+1}I#{image_index+1} (ImageSort)"
        answers << image.key_image?
      end
      [header, answers]
    end

    def box_sort_user_answers(question, user_answers)
      question.answers.each do |answer|
        email = answer.user.email
        user_answers[email] ||= []
        question.images.each do |image|
          user_selection = answer.contents.answers.find {|a| a['id'] == image.id}
          option = question.contents.option(user_selection['optionUid'])
          user_answers[email] << (option && option[:text])
        end
      end
    end

    CSV.generate do |csv|
      csv << [title]
      csv << ["Users Started", "Users Completed", "Questions"]
      csv << [started_count, completed_count, question_count]
      csv << []
      questions_header = ['User']
      correct_answers = ['Correct Answers']
      user_answers = {}
      ordered_questions.each_with_index do |question, index|
        if question.symbolize_question_type == :multiple_choice
          questions_header << "Q#{index+1} (MultChoice)"
          correct_answers << question.contents.correct_option_display
          question.answers.each do |answer|
            email = answer.user.email
            user_answers[email] ||= []
            user_answers[email] << question.contents.option_display(answer.contents.uid)
          end
        else
          header,answers = box_sort_header_and_answers(question, index)
          questions_header += header
          correct_answers += answers
          box_sort_user_answers(question, user_answers)
        end
      end
      csv << questions_header
      csv << correct_answers
      user_answers.each do |email, answers|
        csv << [email] + answers
      end
    end
  end

  private

  def question_class_from_type(question_type)
    question_type.to_s.classify.constantize
  end

end

