class CookHistoryItem < ActiveRecord::Base
  attr_accessible :type, :user_content_id, :user_id
end
