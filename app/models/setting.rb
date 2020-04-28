class Setting < ActiveRecord::Base

  def self.footer_image
    if self.any?
      self.last.footer_image
    else
      "final_dish_IMG_5402.jpg"
    end
  end

end
