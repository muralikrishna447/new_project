class EmbedPdf < ApplicationRecord
  extend FriendlyId

  friendly_id :slug_candidates, use: [:slugged, :finders]

  def slug_candidates
    [
      [:title, SecureRandom.uuid]
    ]
  end

  validates :title, :image_id, :image_alt, :pdf_id, :slug, presence: true

  def image_url
    return if image_id.blank?
    image = JSON.parse(image_id)
    return image['url'] if image.present? && image['url'].present?
  end
end
