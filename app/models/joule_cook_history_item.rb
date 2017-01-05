class JouleCookHistoryItem < ActiveRecord::Base
  acts_as_paranoid
  
  attr_accessible :idempotency_id, :start_time, :started_from
  :cook_time, :guide_id, :holding_temperature, 
  :program_type, :set_point, :timer_id, :cook_id,
  :delayed_start, :wait_for_preheat, :predictive
  
  belongs_to :user
  
  before_create :generate_unique_uuid
  validates_uniqueness_of :uuid

  private
  
  def generate_unique_uuid
    begin
      self.uuid = SecureRandom.uuid
    end while self.class.where(uuid: self.uuid).exists?
  end
  
end
