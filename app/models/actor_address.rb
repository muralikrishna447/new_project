class ActorAddress < ActiveRecord::Base
  belongs_to :actor, polymorphic: true

  # new for circulator
  # new for circ

  def self.createForActor(actor, address_type)
    # need to sort out transaction scope...
    aa = ActorAddress.new()
    aa.actor = actor
    aa.address_type = address_type
    aa.issued_at = Time.now.to_i
    ActorAddress.transaction do
      aa.save!
      aa.address_id = aa.id
      aa.save!
    end
    aa
  end

  def self.createForCirculator(user, circulator)
    self.createForActor(circulator, 'circulator')
  end

  def self.createForUser(user, circulator)
    self.createForActor(user, 'user_something')
  end

  def current_token
    AuthToken.new claim
  end

  def claim
    {:iat => self.issued_at,
     :address_id => self.address_id,
     :seq => self.sequence}
  end

  def tentative_next
    modified_claim = claim

    modified_claim[:seq] += 1
    modified_claim[:iat] = Time.now.to_i
    AuthToken.new modified_claim
  end

  def valid_token?(auth_token)
    auth_claim = auth_token.claim
    if self.address_id != auth_claim[:address_id]
      # log something!
      return false
    end
    if self.sequence != auth_claim[:seq]
      return false
    end
  end
end
