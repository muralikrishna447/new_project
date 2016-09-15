require 'external_service_token_checker'



describe ExternalServiceTokenChecker do
  before :each do
    issued_at = (Time.now.to_f * 1000).to_i
    service_claim = {
      iat: issued_at,
      service: 'Messaging'
    }
    @key = OpenSSL::PKey::RSA.new ENV["AUTH_SECRET_KEY"], 'cooksmarter'
    @service_token = JSON::JWT.new(service_claim.as_json).sign(@key.to_s).to_s
  end
  describe 'external_service_token_checker' do
    it 'should check an auth header to see if it belongs to an authorized external service' do
      request_auth = @service_token
      r1 = ExternalServiceTokenChecker.is_authorized(request_auth)
      expect(r1).to eq true
    end
  end
end
