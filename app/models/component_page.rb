class ComponentPage < ActiveRecord::Base
  attr_accessible :component_id, :position, :page_id

  belongs_to :component
  belongs_to :page
end
