module ExternalServiceTokenChecker

  class AuthenticationError < StandardError
  end

  def self.is_authenticated(request_auth)
    begin
      token = self.get_valid_service_token(request_auth)
      return true
    rescue AuthenticationError => e
      return false
    end
  end

  def self.get_valid_service_token(request_auth)
    if request_auth
      token_string = request_auth.split(' ').last
      raise AuthenticationError.new('empty token string') unless token_string
      begin
        token = AuthToken.from_string(token_string)
      rescue JSON::JWS::VerificationFailed, JSON::JWT::InvalidFormat => e
        msg = "External servive token check: service token verification failed"
        Rails.logger.info(msg)
        raise AuthenticationError.new(msg)
      end
    else
      msg = "External servive token check:No request authorization provided"
      Rails.logger.info(msg)
      raise AuthenticationError.new(msg)
    end
    return token
  end

  def self.is_authorized(request_auth, allowed_services)
    begin
      token = self.get_valid_service_token(request_auth)
      if allowed_services.include? token.claim['service']
        return true
      else
        Rails.logger.info "External servive token check: unauthorized claim: #{token.claim.inspect}"
        return false
      end
    rescue AuthenticationError => e
      return false
    end
  end
end
