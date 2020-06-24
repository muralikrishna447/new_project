class AddIsPromotionToPages < ActiveRecord::Migration[5.2]
  def change
    add_column :pages, :is_promotion, :boolean
    add_column :pages, :discount_id, :string
    add_column :pages, :redirect_path, :string
  end
end
