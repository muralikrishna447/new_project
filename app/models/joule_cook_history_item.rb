class JouleCookHistoryItem < ActiveRecord::Base
  acts_as_paranoid
  
  HASHID_SALT = '3cc6500d43f5b84uyg7gyi13889639'
  @@hashids = Hashids.new(HASHID_SALT, 8)
  
  @@page_size = 20
  @@page_search_chunk_size = 50
  
  attr_accessible :idempotency_id, :start_time, :started_from,
  :cook_time, :guide_id, :program_type, :set_point, :timer_id, :cook_id,
  :wait_for_preheat, :program_id
  
  belongs_to :user
  
  validates :idempotency_id, presence: true
  validates :idempotency_id, length: { minimum: 16 }
  validates :start_time, presence: true
  validates :start_time, numericality: true
  validates :set_point, presence: true
  validates :set_point, numericality: true
  validates :cook_id, presence: true
  validates :cook_time, presence: true, if: 'automatic?'
  validates :guide_id, presence: true, if: 'automatic?'
  validates :program_type, presence: true, if: 'automatic?'
  validates :set_point, presence: true, if: 'automatic?'
  validates :timer_id, presence: true, if: 'automatic?'
  validates :cook_id, presence: true, if: 'automatic?'
  validates :program_id, presence: true, if: 'automatic?'
  
  def self.find_by_external_id(external_id)
    self.find_by_id @@hashids.decode(external_id)
  end
  
  def external_id
    @@hashids.encode(self.id)
  end
  
  def automatic?
    self.program_type == 'AUTOMATIC'
  end
  
  def self.collapse_to_first_of_each_cook_id(array)
    first_entries = {}
    array.each do |entry|
      key = entry.cook_id
      first_entries[key] = entry unless first_entries[key]
    end
    first_entries.values
  end
  
  def self.entries_from_cursor(association, cursor)
    if cursor
      association = association.where('id < ?', cursor)
    end
    entries_desc = association.order('id DESC').first(@@page_search_chunk_size)
    end_of_list = entries_desc.length < @@page_search_chunk_size
    entries_collapsed = JouleCookHistoryItem.collapse_to_first_of_each_cook_id(entries_desc)
    { entries: entries_collapsed, end_of_list: end_of_list }
  end
  
  def self.group_paginate(association, cursor)  
    page = []
    current_cursor = cursor
    
    loop do
      cursor_results = self.entries_from_cursor(association, current_cursor)
      page.push(cursor_results[:entries]).flatten!
      next_cursor = cursor_results[:entries].last.id
      additional_needed = (@@page_size > page.length)
      end_of_list = cursor_results[:end_of_list]
      if !additional_needed || end_of_list
        next_cursor = false if end_of_list
        return {
          body: page.first(@@page_size),
          next_cursor: next_cursor,
          additional_needed: additional_needed,
          end_of_list: end_of_list
        }
      else
        current_cursor = next_cursor
      end
    end
    
  end
  
end
