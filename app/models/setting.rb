class Setting < ActiveRecord::Base
  attr_accessible :footer_image, :featured_activity_1_id, :featured_activity_2_id, :featured_activity_3_id, :global_message, :global_message_active, :forum_maintenance, :hero_cms_title, :hero_cms_image, :hero_cms_description, :hero_cms_button_text, :hero_cms_url

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

  def self.get_hero_cms
    current_settings = Setting.last
    return { title: current_settings[:hero_cms_title], image: current_settings[:hero_cms_image], description: current_settings[:hero_cms_description], url: current_settings[:hero_cms_url], button_text: current_settings[:hero_cms_button_text]}
  end
end
