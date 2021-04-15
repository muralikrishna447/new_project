class AddAltColumnStepImage < ActiveRecord::Migration[5.2]
  def change
    add_column :steps, :appliance_instruction_image_alt, :text
    add_column :steps, :image_alt, :text
  end
end
