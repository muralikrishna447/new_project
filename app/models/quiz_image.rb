class QuizImage < ActiveRecord::Base
  belongs_to :quiz

  attr_accessible :filename, :url, :caption, :quiz_id
end

