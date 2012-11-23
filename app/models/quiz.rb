class Quiz < ActiveRecord::Base
  extend FriendlyId
  friendly_id :title, use: :slugged

  belongs_to :activity

  has_many :questions

  attr_accessible :title, :activity_id

  def add_multiple_choice_question
    question = MultipleChoiceQuestion.create
    questions << question
    question
  end
end
