module ExternalServiceTokenChecker
  def self.is_authorized(request_auth)
    allowed_services = ['Messaging']
    if request_auth
      begin
        token_string = request_auth.split(' ').last
        return false unless token_string
        token = AuthToken.from_string(token_string)
      rescue JSON::JWS::VerificationFailed, JSON::JWT::InvalidFormat => e
        Rails.logger.info ("External servive token check: service token verification failed")
        return false
      end
      if allowed_services.include? token.claim['service']
        return true
      else
        Rails.logger.info "External servive token check: unauthorized claim: #{token.claim.inspect}"
        return false
      end
    else
      Rails.logger.info "External servive token check:No request authorization provided"
      return false
    end
  end
end
