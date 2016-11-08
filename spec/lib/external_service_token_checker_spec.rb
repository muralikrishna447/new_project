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
    it 'should handle nil' do
      request_auth = @service_token
      r1 = ExternalServiceTokenChecker.is_authorized(nil)
      expect(r1).to eq false
    end
    it 'should handle empty string' do
      request_auth = @service_token
      r1 = ExternalServiceTokenChecker.is_authorized('')
      expect(r1).to eq false
    end

    it 'should handle malformed token' do
      request_auth = @service_token
      malformed_tokens = [
        'alksdfj.asdfksdajfsadf.adsfjaskdfj3241',
        'hello my name is dr greenthumb.123.123',
        '     ',
      ]
      for t in malformed_tokens
        expect(ExternalServiceTokenChecker.is_authorized(t)).to eq false
      end
    end
  end
end
