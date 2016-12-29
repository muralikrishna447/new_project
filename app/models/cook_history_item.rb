class CookHistoryItem < ActiveRecord::Base
  attr_accessible :history_item_type, :user_content_id, :user_id, :joule_cook_history_program_attributes
  has_one :joule_cook_history_program, :dependent => :destroy
  accepts_nested_attributes_for :joule_cook_history_program
  
end
