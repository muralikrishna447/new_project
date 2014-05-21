class AddPresentationHintsToStep < ActiveRecord::Migration
  def change
    add_column :steps, :presentation_hints, :text, :default => "{}"
  end
end
