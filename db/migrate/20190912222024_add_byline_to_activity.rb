class AddBylineToActivity < ActiveRecord::Migration
  def change
    add_column :activities, :byline, :string
  end
end
