class Question < ActiveRecord::Base
  self.inheritance_column = :question_type

  belongs_to :quiz

  attr_accessible :title, :quiz_id, :contents
end

class MultipleChoiceQuestion < Question
  require_relative 'question/multiple_choice_question_contents'
  serialize :contents, MultipleChoiceQuestionContents
end

