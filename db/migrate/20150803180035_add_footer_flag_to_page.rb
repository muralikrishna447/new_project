class AddFooterFlagToPage < ActiveRecord::Migration[5.2]
  def change
    add_column :pages, :show_footer, :boolean, default: false
  end
end
