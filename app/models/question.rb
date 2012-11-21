class Question < ActiveRecord::Base
  QUESTION_TYPES = %w[multiple_choice]

  belongs_to :quiz

  serialize :contents

  attr_accessible :title, :quiz_id, :contents

  validates_inclusion_of :question_type, in: QUESTION_TYPES
end
