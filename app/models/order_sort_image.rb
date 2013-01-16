class OrderSortImage < ActiveRecord::Base
  belongs_to :question,
             class_name: 'OrderSortQuestion'

  has_one :image,
          as: :imageable,
          dependent: :destroy

  delegate :filename,
           :filename=,
           :url,
           :url=,
           :caption,
           :caption=,
           to: :image,
           allow_nil: true
end
