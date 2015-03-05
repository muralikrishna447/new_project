class AddHomeHeroCmsToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :hero_cms_title, :string, default: ""
    add_column :settings, :hero_cms_image, :text, default: ""
    add_column :settings, :hero_cms_description, :text, default: ""
    add_column :settings, :hero_cms_button_text, :string, default: ""
    add_column :settings, :hero_cms_url, :string, default: ""
  end
end
