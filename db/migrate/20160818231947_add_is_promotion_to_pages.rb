class AddIsPromotionToPages < ActiveRecord::Migration
  def change
    add_column :pages, :is_promotion, :boolean
    add_column :pages, :discount_id, :string
    add_column :pages, :redirect_path, :string
  end
end