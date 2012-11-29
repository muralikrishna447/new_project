class Question < ActiveRecord::Base
  include RankedModel

  ranks :question_order, with_same: :quiz_id

  self.inheritance_column = :question_type

  belongs_to :quiz

  attr_accessible :quiz_id, :contents, :question_order_position

  after_initialize :init_contents

  scope :ordered, rank(:question_order)

  def update_contents(params)
    self.contents.update(params)
  end

  private
  def init_contents
    return if persisted?
    self.contents = contents_class.new({}) if self.contents.blank?
  end

  def contents_class
    (self.class.name.to_s + 'Contents').constantize
  end
end

