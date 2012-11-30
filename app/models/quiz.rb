class Quiz < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title, use: :slugged

  belongs_to :activity

  has_many :questions

  attr_accessible :title, :activity_id, :start_copy, :end_copy, :published

  scope :published, where(published: true)

  def self.find_published(id, token=nil)
    scope = PrivateToken.valid?(token) ? scoped : published
    scope.find(id)
  end

  def add_multiple_choice_question
    question = MultipleChoiceQuestion.create
    questions << question
    question
  end

  def question_count
    questions.count
  end

  def update_question_order(question_ids)
    question_ids.each do |question_id|
      questions.find(question_id).update_attribute(:question_order_position, :last)
    end
  end
end
