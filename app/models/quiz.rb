class Quiz < ActiveRecord::Base
  belongs_to :activity

  attr_accessible :title, :activity_id
end
