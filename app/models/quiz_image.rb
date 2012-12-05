class QuizImage < ActiveRecord::Base
  belongs_to :quiz

  attr_accessible :filename, :caption, :quiz_id, :url
end

