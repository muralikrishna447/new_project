class Setting < ActiveRecord::Base
  attr_accessible :footer_image, :featured_activity_1_id, :featured_activity_2_id, :featured_activity_3_id

  def self.footer_image
    if self.any?
      self.last.footer_image
    else
      "final_dish_IMG_5402.jpg"
    end
  end

  def self.featured_activities
    featured_activities = []
    current_settings = Setting.last
    if current_settings && current_settings.featured_activity_1_id?
      featured_recipe = Activity.published.includes(:steps).find(current_settings.featured_activity_1_id)
    else
      featured_recipe = Activity.published.recipes.includes(:steps).order('updated_at ASC').last
    end
    if current_settings && current_settings.featured_activity_2_id?
      featured_technique = Activity.published.includes(:steps).find(current_settings.featured_activity_2_id)
    else
      featured_technique = Activity.published.techniques.includes(:steps).order('updated_at ASC').last
    end
    if current_settings && current_settings.featured_activity_3_id?
      featured_science = Activity.published.includes(:steps).find(current_settings.featured_activity_3_id)
    else
      featured_science = Activity.published.sciences.includes(:steps).order('updated_at ASC').last
    end
    featured_activities = [featured_recipe, featured_technique, featured_science].compact
  end
end
