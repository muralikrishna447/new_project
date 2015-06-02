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
        # TODO - the address should be obfuscated
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

  def current_token (exp = nil, restrict_to = nil)
    AuthToken.new claim(exp = exp, restrict_to = restrict_to)
  end

  def claim (exp = nil, restrict_to = nil)
    c = {:iat => self.issued_at,
     :address_id => self.address_id,
     :seq => self.sequence,
     "#{self.actor_type}" => {"id" => self.actor_id}}
    c[:exp] = exp if exp
    c[:restrictTo] = restrict_to if restrict_to
    c
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

  def valid_token?(auth_token, sequence_offset = 0, restrict_to = nil)
    logger.info "Verifying validity for #{auth_token.inspect}"
    auth_claim = auth_token.claim
    if self.address_id != auth_claim[:address_id]
      logger.info "Address does not match"
      return false
    end

    if (self.sequence + sequence_offset) != auth_claim[:seq]
      logger.info "Sequence number does not match"
      return false
    end

    if (auth_claim['restrictTo'] || restrict_to) && auth_claim['restrictTo'] != restrict_to
      logger.info "Required restriction #{restrict_to} does not match"
      return false
    end

    # TODO add expiration logic

    if self.revoked?
      logger.info "Token is revoked"
      return false
    end

    time_now = (Time.now.to_f * 1000).to_i
    if auth_claim[:exp] && auth_claim[:exp] <= time_now
      logger.info "Token expired"
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
    actor_type = actor_type_from_token(token)
    actor_id = token.claim[actor_type]['id']
    address_id = token.claim['address_id']

    aa = ActorAddress.where(actor_type: actor_type, actor_id: actor_id, address_id: address_id).first
    unless aa
      logger.info ("No ActorAddress found for token #{token.claim.inspect}")
      return nil
    end
    aa
  end

  private

  def self.actor_type_from_token (token)
    if token.claim.has_key?("User")
      "User"
    elsif token.claim.has_key?("Circulator")
      "Circulator"
    else
      raise "Token does not contain valid actor type"
    end
  end
end
