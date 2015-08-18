class AddParentTypeAndParentIdToComponents < ActiveRecord::Migration
  def change
    add_column :components, :component_parent_type, :string
    add_column :components, :component_parent_id, :integer
    add_column :components, :position, :integer
  end
end
