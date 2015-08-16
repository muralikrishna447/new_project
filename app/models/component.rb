class Component < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, use: [:slugged]

  attr_accessible :component_type, :meta, :name, :component_parent_type, :component_parent_id, :position, :slug
  serialize :meta, ActiveRecord::Coders::NestedHstore

  validates :component_type, presence: true

  belongs_to :component_parent, polymorphic: true
end
