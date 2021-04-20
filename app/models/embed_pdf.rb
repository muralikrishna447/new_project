class EmbedPdf < ApplicationRecord
  extend FriendlyId

  friendly_id :title, use: [:slugged, :finders]

  validates :title, :image_id, :image_alt, :pdf_id, :slug, presence: true
  validates :title, :slug, uniqueness: true

  def resolve_friendly_id_conflict(candidates)
    errors.add(:slug, 'has already been taken, change title')
  end

  def image_url
    return if image_id.blank?
    image = JSON.parse(image_id)
    return image['url'] if image.present? && image['url'].present?
  end
end
