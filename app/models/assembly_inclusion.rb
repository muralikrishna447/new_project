class AssemblyInclusion < ApplicationRecord

  belongs_to :assembly
  belongs_to :includable, polymorphic: true

  validates_presence_of :includable_type, :includable_id
end
