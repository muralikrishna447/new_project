class MarketplaceGuide < ActiveRecord::Base
  attr_accessible :guide_id, :url, :button_text, :button_text_line_2, :feature_name
end