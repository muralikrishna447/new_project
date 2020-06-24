class AddPresentationHintsToStep < ActiveRecord::Migration[5.2]
  def change
    add_column :steps, :presentation_hints, :text, :default => "{}"
  end
end
