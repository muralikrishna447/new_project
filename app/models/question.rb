class Question < ActiveRecord::Base
  belongs_to :quiz

  attr_accessible :title, :quiz_id
end
