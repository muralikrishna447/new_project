class ActorAddress < ActiveRecord::Base
  belongs_to :actor, polymorphic: true

  ADDRESS_LENGTH = 16
  HASHID_SALT = '3cc6500d43f5b8456bf164a313889639'
  SEQUENCE_GENERATED_ADDRESS_PREFIX = 'a00000'
  @@hashids = Hashids.new(HASHID_SALT, ADDRESS_LENGTH - SEQUENCE_GENERATED_ADDRESS_PREFIX.length, '01233456789abcdef')

  def addressable_addresses
    if self.actor_type == 'User'
      actor_class = User
      method = 'owned_circulator_ids'
      other_actor = 'Circulator'
    elsif self.actor_type == 'Circulator'
      actor_class = Circulator
      method = 'user_ids'
      other_actor = 'User'
    else
      logger.debug "No addressable actors for #{self.actor_type}"
      return []
    end

    actor = actor_class.find(self.actor_id)
    other_ids = actor.method(method).call()
    logger.debug "Trying to find #{other_actor} #{other_ids}"
    addresses = ActorAddress.where(
      actor_type: other_actor, actor_id: other_ids, status: 'active'
    )
    addresses
  end

  def self.create_for_actor(actor, opts = {})
    logger.info "Creating new ActorAddress for #{actor} with opts #{opts.inspect}"
    aa = ActorAddress.new()
    aa.actor = actor
    if opts.has_key? :client_metadata
      aa.client_metadata = opts[:client_metadata]
    end
    aa.issued_at = Time.now.to_i
    aa.status = 'active' # Nothing beats ad-hoc enums - what's the modern rails way?
    if opts.has_key? :unique_key
      aa.unique_key = opts[:unique_key]
    end

    ActorAddress.transaction do
      # save first only so we can re-use id for address_id when not specified
      aa.save!
      if opts.has_key? :address_id
        address_id = opts[:address_id]
        # TODO -clean up exceptions and bubble up to API level
        unless address_id.length == 16
          raise ArgumentError.new ("Invalid address_id length [#{address_id.length}] - length must be 16 hex chars")
        end

        unless address_id =~ /^[0-9a-f]+$/
          throw Error.new ("Invalid address_id [#{address_id}] contains non-hex characters")
        end
        aa.address_id = address_id
      else
        hashid = SEQUENCE_GENERATED_ADDRESS_PREFIX + @@hashids.encode(aa.id)
        if hashid.length > ADDRESS_LENGTH
          # This should never happpen given input is auto-incrementing field
          raise "Hashid length is too long - id [#{hashid}]"
        end

        aa.address_id = hashid
      end
      aa.save!
    end
    logger.info ("Created new ActorAddress #{aa.inspect}")
    aa
  end

  def self.create_for_circulator(circulator, opts = {})
    opts[:client_metadata] = 'circulator'
    opts[:address_id] = circulator.circulator_id
    self.create_for_actor(circulator, opts)
  end

  def self.create_for_user(user, opts = {})
    self.create_for_actor(user, opts)
  end

  def current_token (opts = {}) #exp = nil, restrict_to = nil)
    exp = opts[:exp]
    restrict_to = opts[:restrict_to]
    AuthToken.new claim(exp = exp, restrict_to = restrict_to)
  end

  def claim (exp = nil, restrict_to = nil)
    c = {:iat => self.issued_at,
     :a => self.address_id,
     :seq => self.sequence}
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

  # TODO - fork here
  def valid_token?(auth_token, sequence_offset = 0, restrict_to = nil)
    logger.info "Testing validity of #{auth_token.inspect}"
    return false if auth_token.nil?

    valid = true

    auth_claim = auth_token.claim

    old_address_matches = self.address_id == auth_claim[:address_id]
    new_address_matches = self.address_id == auth_claim[:a]

    # either old or new should match, both matching should never happen and
    # neither matching is an invalid token
    if !(old_address_matches ^ new_address_matches)
      logger.info "Address does not match"
      valid = false
    end

    if (self.sequence + sequence_offset) != auth_claim[:seq]
      logger.info "Sequence number does not match"
      valid = false
    end

    if (auth_claim['restrictTo'] || restrict_to) && auth_claim['restrictTo'] != restrict_to
      logger.info "Required restriction #{restrict_to} does not match"
      valid = false
    end

    if self.revoked?
      logger.info "Token is revoked"
      valid = false
    end

    time_now = Time.now.to_i
    if auth_claim[:exp] && auth_claim[:exp] <= time_now
      logger.info "Token expired"
      valid = false
    end

    unless valid
      logger.info "Invalid token.  Token claim: [#{auth_claim.inspect}] Actor address: [#{self.inspect}]"
    end

    return valid
  end

  def double_increment()
    self.sequence = self.sequence + 2
    self.save
  end

  def revoke
    self.status = 'revoked'
    self.save
  end

  def revoked?
    self.status == "revoked"
  end

  def self.revoke_all_for_user(user)
    logger.info("Setting all actor address statuses to revoked for user with id #{user.id}")
    ActorAddress.where(actor_id: user.id).update_all(status: 'revoked')
  end

  # fork here
  def self.find_for_token(token)
    logger.info "Finding actor address for token [#{token.inspect}]"
    old_address_id = token.claim['address_id']
    new_address_id = token.claim['a']

    if new_address_id
      addresses = ActorAddress.where(address_id: new_address_id, status: 'active')
      if addresses.length > 1
        raise "Unexpectedly found more than one active address with id #{new_address_id} [#{addresses.inspect}]"
      end
      aa = addresses.first
    elsif old_address_id
      actor_type = actor_type_from_token(token)
      actor_id = token.claim[actor_type]['id']

      aa = ActorAddress.where(actor_type: actor_type, actor_id: actor_id, address_id: old_address_id).first
      unless aa
        logger.info ("No ActorAddress found for token #{token.claim.inspect}")
        return nil
      end
      return aa
    else
      logger.info ("Token contains neither 'address_id' or 'a' value")
      return nil
    end
      # Old style token


  end

  def self.find_for_user_and_unique_key(user, unique_key)
    actor_type = 'User'
    actor_id = user.id
    aa = ActorAddress.where(actor_type: actor_type, actor_id: actor_id, unique_key: unique_key).first
    unless aa
      logger.info ("No ActorAddress found for user [#{user.inspect}] and unique key [#{unique_key}]")
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
