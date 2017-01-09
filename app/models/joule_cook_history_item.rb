class JouleCookHistoryItem < ActiveRecord::Base
  acts_as_paranoid
  
  paginates_per 20
  
  attr_accessible :idempotency_id, :start_time, :started_from,
  :cook_time, :guide_id, :holding_temperature, 
  :program_type, :set_point, :timer_id, :cook_id,
  :delayed_start, :wait_for_preheat, :predictive, :program_id
  
  belongs_to :user
  
  before_create :generate_unique_uuid
  
  validates_uniqueness_of :uuid
  
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

  private
  
  def generate_unique_uuid
    begin
      self.uuid = SecureRandom.uuid
    end while self.class.where(uuid: self.uuid).exists?
  end
  
  def automatic?
    self.program_type == 'AUTOMATIC'
  end
  
end
