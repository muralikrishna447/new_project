class BoxSortImage < ActiveRecord::Base
  belongs_to :question, class_name: 'BoxSortQuestion'
  has_one :image, as: :imageable

  delegate :filename, :url, :caption, to: :image, allow_nil: true

  attr_accessible :key_image, :key_rationale, :question_id
end

