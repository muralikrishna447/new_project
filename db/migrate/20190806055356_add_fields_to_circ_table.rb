class AddFieldsToCircTable < ActiveRecord::Migration[5.2]
  def change
    add_column :circulators, :hardware_options, :integer
    add_column :circulators, :hardware_version, :string
    add_column :circulators, :build_date, :integer
    add_column :circulators, :model_number, :string
    add_column :circulators, :pcba_revision, :string
  end
end
