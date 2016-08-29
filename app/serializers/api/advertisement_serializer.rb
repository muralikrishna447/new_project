class Api::AdvertisementSerializer < ApplicationSerializer
  format_keys :lower_camel
  attributes :image, :title, :description, :button_title, :url, :campaign

  def image
    filepicker_to_s3_url(object.image)
  end
end
