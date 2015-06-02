class ActorAddress < ActiveRecord::Base
  belongs_to :actor, polymorphic: true

  def self.create_for_actor(actor, client_metadata, address_id)
    logger.info "Creating new ActorAddress for #{actor} with metadata #{client_metadata}"
    aa = ActorAddress.new()
    aa.actor = actor
    aa.client_metadata = client_metadata
    aa.issued_at = Time.now.to_i
    aa.status = 'active' # Nothing beats ad-hoc enums - what's the modern rails way?

    ActorAddress.transaction do
      # save first only so we can re-use id for address_id when not specified
      aa.save!
      if address_id
        aa.address_id = address_id
      else
        aa.address_id = aa.id.to_s
      end
      aa.save!
    end
    logger.info ("Created new ActorAddress #{aa.inspect}")
    aa
  end

  def self.create_for_circulator(circulator)
    self.create_for_actor(circulator, 'circulator', circulator.circulator_id)
  end

  def self.create_for_user(user, client_metadata)
    self.create_for_actor(user, client_metadata, nil)
  end

  def current_token
    AuthToken.new claim
  end

  def claim
    {:iat => self.issued_at,
     :address_id => self.address_id,
     :seq => self.sequence,
     "#{self.actor_type}" => {"id" => self.actor_id}}
  end

  def tentative_next_token
    modified_claim = claim

    modified_claim[:seq] += 1
    modified_claim[:iat] = Time.now.to_i
    AuthToken.new modified_claim
  end

  def increment_to(token)
    unless valid_token?(token, 1)
      raise "Invalid token"
    end

    self.issued_at = token['iat']
    self.sequence = self.sequence + 1
    self.save
  end

  def valid_token?(auth_token, sequence_offset = 0)
    auth_claim = auth_token.claim
    if self.address_id != auth_claim[:address_id]
      logger.info "Address does not match"
      return false
    end

    if (self.sequence + sequence_offset) != auth_claim[:seq]
      logger.info "Sequence number does not match"
      return false
    end

    # TODO add expiration logic

    if self.revoked?
      logger.info "Token is revoked"
      return false
    end

    return true
  end

  def double_increment()
    self.sequence = self.sequence + 2
    self.save
  end

  def revoked?
    self.status == "revoked"
  end

  def self.find_for_token(token)
    if token.claim.has_key?("User")
      actor_type = "User"
    elsif token.claim.has_key?("Circulator")
      actor_type = "Circulator"
    else
      raise "Token does not contain valid actor type"
    end

    actor_id = token.claim[actor_type]['id']
    address_id = token.claim['address_id']
    aa = ActorAddress.where(actor_type: actor_type, actor_id: actor_id, address_id: address_id).first
    unless aa
      logger.info ("No ActorAddress found for token #{token.claim.inspect}")
      return nil
    end
    return aa
  end
end
