class CookHistoryItem < ActiveRecord::Base
  attr_accessible :type, :user_content_id, :user_id
  
  def new_program(program: {})
    case self.type
    when 'joule'
      JouleCookHistoryProgram.new(program)
    end
  end
  
end
