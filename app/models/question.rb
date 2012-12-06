class Question < ActiveRecord::Base
  include RankedModel
  include SerializeableContents

  ranks :question_order, with_same: :quiz_id

  self.inheritance_column = :question_type

  belongs_to :quiz
  has_many :answers
  has_one :image, as: :imageable

  attr_accessible :quiz_id, :contents

  after_initialize :init_contents

  scope :ordered, rank(:question_order)

  def update_image(image_params)
    image = Image.new unless image.present?
    image.update_whitelist_attributes(image_params)
    image
  end

  def score(answer)
    answer.question = self
    answer.correct = correct(answer)
    answer.save!
    answer
  end

  def correct(answer)
    self.contents.correct(answer.contents)
  end

  def answer_count
    answers.count
  end
end

