class AddActsAsRevisionable < ActiveRecord::Migration[5.2]
  def up
    ActsAsRevisionable::RevisionRecord.create_table
  end

  def down
  end
end
