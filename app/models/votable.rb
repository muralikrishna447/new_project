class Votable < ActiveRecord::Base
  attr_accessible :description, :poll_id, :status, :title

  belongs_to :poll
end
