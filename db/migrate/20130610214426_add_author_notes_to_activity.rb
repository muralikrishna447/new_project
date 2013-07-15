class AddAuthorNotesToActivity < ActiveRecord::Migration
  def change
    add_column :activities, :author_notes, :string
  end
end
