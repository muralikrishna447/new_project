class AddHomeHeroCmsToSettings < ActiveRecord::Migration
  def change
    add_column :settings, :hero_cms_title, :string
    add_column :settings, :hero_cms_image, :string
    add_column :settings, :hero_cms_description, :text
    add_column :settings, :hero_cms_button_text, :string
    add_column :settings, :hero_cms_url, :string
  end
end
