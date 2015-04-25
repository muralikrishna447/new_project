class Component < ActiveRecord::Base
  attr_accessible :component_type, :metadata, :mode
  serialize :metadata, ActiveRecord::Coders::NestedHstore
  
  validates :component_type, presence: true
end
