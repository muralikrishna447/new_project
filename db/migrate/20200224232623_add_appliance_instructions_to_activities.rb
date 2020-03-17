class AddApplianceInstructionsToActivities < ActiveRecord::Migration
  def change
    add_column :steps, :appliance_instruction_text, :text
    add_column :steps, :appliance_instruction_image, :text
  end
end
