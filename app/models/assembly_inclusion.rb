class AssemblyInclusion < ActiveRecord::Base
  attr_accessible :includable_id, :includable_type, :position, :include_disqus

  belongs_to :assembly
  belongs_to :includable, polymorphic: true

  validates_presence_of :includable_type, :includable_id
end
