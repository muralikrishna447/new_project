class JouleCookHistoryItem < ActiveRecord::Base
  acts_as_paranoid
  
  HASHID_SALT = '3cc6500d43f5b84uyg7gyi13889639'
  @@hashids = Hashids.new(HASHID_SALT, 8)
  
  paginates_per 20
  
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
  
end