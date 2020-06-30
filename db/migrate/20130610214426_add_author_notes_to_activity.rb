class AddAuthorNotesToActivity < ActiveRecord::Migration[5.2]
  def change
    add_column :activities, :author_notes, :string
  end
end
