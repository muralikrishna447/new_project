class Component < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, use: [:slugged, :history]

  attr_accessible :component_type, :meta, :name
  serialize :meta, ActiveRecord::Coders::NestedHstore

  validates :component_type, presence: true
end
