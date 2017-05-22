class GuideActivity < ActiveRecord::Base
  validates_uniqueness_of :guide_id
end

