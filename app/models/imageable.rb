module Imageable
  extend ActiveSupport::Concern

  included do
    has_one :image, as: :imageable
  end

  def update_image(image_params)
    unless image_params.present?
      self.image.destroy if self.image.present?
    else
      self.image = Image.new unless self.image.present?
      self.image.update_whitelist_attributes(image_params)
      self.image
    end
  end

end
