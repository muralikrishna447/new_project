class CookHistoryItem < ActiveRecord::Base
  acts_as_paranoid
  attr_accessible :history_item_type, :user_id, 
    :joule_cook_history_program_attributes, :uuid
  belongs_to :user
  has_one :joule_cook_history_program, :dependent => :destroy
  accepts_nested_attributes_for :joule_cook_history_program
  
  before_create :generate_unique_uuid
  validates_uniqueness_of :uuid

  private
  
  def generate_unique_uuid
    begin
      self.uuid = SecureRandom.uuid
    end while self.class.where(uuid: self.uuid).exists?
  end
  
end
