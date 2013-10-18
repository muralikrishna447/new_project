class ChangeAuthorNotesToText < ActiveRecord::Migration
  def up
    change_column :activities, :author_notes, :text
  end

  def down
    change_column :activities, :author_notes, :string
  end
end
