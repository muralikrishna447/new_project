require 'json'

class Page < ActiveRecord::Base
  extend FriendlyId
  include PublishableModel

  friendly_id :title, use: [:slugged, :history, :finders]

  validates :title, presence: true
  # validates :content, presence: true

  has_many :likes, as: :likeable, dependent: :destroy

  has_many :components, -> { order 'position' }, as: :component_parent
  accepts_nested_attributes_for :components, allow_destroy: true

  def featured_image
    image_id
  end

  def featured_image_url
    if featured_image.present?
      begin
        image = JSON.parse(featured_image)
        if image.present? && image["url"].present?
          return image["url"]
        end
      rescue JSON::ParserError
        Rails.logger.error("Page.featured_image_url failed to parse featured_image for page title=#{page.title}")
      end
    end

    nil
  end
end
