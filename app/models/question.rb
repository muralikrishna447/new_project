class Question < ActiveRecord::Base
  self.inheritance_column = :question_type

  belongs_to :quiz

  attr_accessible :title, :quiz_id, :contents

  after_initialize :init_contents

  private
  def init_contents
    contents_class = (MultipleChoiceQuestion.to_s + 'Contents').constantize
    self.contents = contents_class.new({}) if self.contents.blank?
  end
end
