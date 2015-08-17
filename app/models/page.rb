class Page < ActiveRecord::Base
  extend FriendlyId
  attr_accessible :title, :content, :image_id, :primary_path, :short_description, :show_footer, :components_attributes

  friendly_id :title, use: [:slugged, :history]

  validates :title, presence: true
  # validates :content, presence: true

  has_many :likes, as: :likeable, dependent: :destroy

  has_many :components, as: :component_parent, order: :position
  accepts_nested_attributes_for :components, allow_destroy: true

  def featured_image
    image_id
  end
end
