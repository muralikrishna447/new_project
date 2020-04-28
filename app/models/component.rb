class Component < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, use: [:slugged]

  serialize :meta, ActiveRecord::Coders::NestedHstore

  validates :component_type, presence: true

  belongs_to :component_parent, polymorphic: true
end
