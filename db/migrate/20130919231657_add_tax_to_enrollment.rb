class AddTaxToEnrollment < ActiveRecord::Migration
  def change
    add_column :enrollments, :sales_tax, :decimal, :precision => 8, :scale => 2, :default => 0
  end
end
