class CookHistoryItem < ActiveRecord::Base
  attr_accessible :program_type, :user_content_id, :user_id, :joule_cook_history_program_attributes
  has_one :joule_cook_history_program
  accepts_nested_attributes_for :joule_cook_history_program
  
end
