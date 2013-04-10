class AddActsAsRevisionable < ActiveRecord::Migration
  def up
    ActsAsRevisionable::RevisionRecord.create_table
  end

  def down
  end
end
