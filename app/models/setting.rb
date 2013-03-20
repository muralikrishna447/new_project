class Setting < ActiveRecord::Base
  attr_accessible :footer_image

  def self.footer_image
    if self.any?
      self.last.footer_image
    else
      "final_dish_IMG_5402.jpg"
    end
  end
end
