class Api::EmbedPdfSerializer < ApplicationSerializer
  format_keys :lower_camel
  attributes :title, :image_alt, :image_longdesc, :image_url, :pdf_url

  def image_url
    filepicker_to_s3_url(object.image_id)
  end

  def pdf_url
    object.pdf_id&.gsub("www.filepicker.io", "d3awvtnmmsvyot.cloudfront.net")
  end
end
