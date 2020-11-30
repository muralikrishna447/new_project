class AddApplianceInstructionImageTypeInSteps < ActiveRecord::Migration[5.2]
  def change
    add_column :steps, :appliance_instruction_image_type, :integer, default: 0
  end
end
