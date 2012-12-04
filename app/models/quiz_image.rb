class QuizImage < ActiveRecord::Base
  belongs_to :quiz

  attr_accessible :file_name, :caption, :quiz_id
end

