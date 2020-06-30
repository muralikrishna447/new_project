class ChangeAuthorNotesToText < ActiveRecord::Migration[5.2]
  def up
    change_column :activities, :author_notes, :text
  end

  def down
    change_column :activities, :author_notes, :string
  end
end
