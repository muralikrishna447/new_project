class AddFooterFlagToPage < ActiveRecord::Migration
  def change
    add_column :pages, :show_footer, :boolean, default: false
  end
end
