class CopyController < ApplicationController
  include ActionCaching

  before_filter :authenticate_user!, only: :thank_you

  [
    :thank_you_intro, :thank_you_image_left, :thank_you_image_left_caption,
    :thank_you_image_middle, :thank_you_image_middle_caption, :thank_you_image_right,
    :thank_you_image_right_caption, :terms_of_service, :privacy_policy, :licensing
  ].each do |key|
    expose(key) { Copy.find_by_location(key.to_s.dasherize)}
  end

  expose(:active_tab) { params[:type].blank? ? 'terms' : params[:type] }
end

