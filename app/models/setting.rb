class Setting < ActiveRecord::Base
  attr_accessible :footer_image, :featured_activity_1_id, :featured_activity_2_id, :featured_activity_2_id

  def self.footer_image
    if self.any?
      self.last.footer_image
    else
      "final_dish_IMG_5402.jpg"
    end
  end
end
