require 'spec_helper'

describe CsAuth::Apple do
  let(:jwk_set_raw) { File.read(Rails.root.join('config/apple-auth-jwks.json')) }
  let(:jwk_set) { JSON::JWK::Set.new(JSON.parse(jwk_set_raw)) }

  describe 'live_jwk_set' do

    before :each do
       WebMock.stub_request(:get, 'https://appleid.apple.com/auth/keys')
          .to_return(status: status, body: jwk_set_raw, headers: {})
    end

    context 'response has code 200' do
      let(:status) { 200 }

      it 'returns jwk set' do
        expect(CsAuth::Apple.live_jwk_set).to eq(jwk_set)
      end
    end

    context 'response code is not 200' do
      let(:status) { 500 }

      it 'raises exception' do
        expect { CsAuth::Apple.live_jwk_set }.to raise_error
      end
    end
  end

  describe 'jwk_set' do
    before :each do
      Rails.cache.delete(CsAuth::Apple::JWK_CACHE_KEY)
    end

    context 'live jwk set fetch successful' do
      before :each do
        allow(CsAuth::Apple).to receive(:live_jwk_set).and_return(jwk_set)
      end

      it 'returns live jwk set' do
        expect(CsAuth::Apple.jwk_set).to eq(jwk_set)
      end
    end
    context 'live jwk set fetch unsuccessful' do
      let(:fallback) { 'fallback' }

      before :each do
        CsAuth::Apple.initialize_fallback_jwk_set(fallback)
        allow(CsAuth::Apple).to receive(:live_jwk_set).and_raise('error')
      end

      it 'returns fallback jwk set' do
        expect(CsAuth::Apple.jwk_set).to eq(fallback)
      end
    end
  end

  describe 'decode_and_validate_token' do
    let(:identity_token) { 'identity_token' }
    let(:decoded_token) { { 'aud' => client_id } }
    let(:apple_user_id) { 'apple_user_id' }
    let(:auth_code) { 'auth_code' }
    let(:client_id) { 'client_id' }
    let(:authorized_token) { { 'sub' => apple_user_id } }

    it 'decodes and validates token' do
      allow(CsAuth::Apple).to receive(:decode_token).with(identity_token).and_return(decoded_token)
      allow(CsAuth::Apple).to receive(:authorized_token_for_code).with(auth_code, client_id).and_return(authorized_token)
      allow(CsAuth::Apple).to receive(:validate_decoded_token).with(authorized_token, apple_user_id)
      allow(CsAuth::Apple).to receive(:validate_decoded_token).with(decoded_token, apple_user_id)
      expect(CsAuth::Apple.decode_and_validate_token(identity_token, auth_code)).to eq(decoded_token)
    end
  end

  describe 'authorized_token_for_code' do
    let(:auth_code) { 'auth_code' }
    let(:client_id) { 'client_id' }
    let(:client_secret) { 'client_secret' }
    let(:apple_request_params) do
      {
        client_id: client_id,
        client_secret: client_secret,
        code: auth_code,
        grant_type: 'authorization_code'
      }
    end

    before :each do
      allow(CsAuth::Apple).to receive(:client_secret).with(client_id).and_return(client_secret)
      WebMock.stub_request(:post, 'https://appleid.apple.com/auth/token')
          .with(body: apple_request_params)
          .to_return(status: status, body: response, headers: {})
    end

    context 'authorization request returns 400' do
      let(:status) { 400 }
      let(:response) { '{}' }

      it 'raises InvalidTokenError' do
        expect{ CsAuth::Apple.authorized_token_for_code(auth_code, client_id) }.to raise_error CsAuth::Apple::InvalidTokenError
      end
    end

    context 'authorization request returns non-400 error' do
      let(:status) { 500 }
      let(:response) { '{}' }

      it 'raises exception' do
        expect{ CsAuth::Apple.authorized_token_for_code(auth_code, client_id) }.to raise_error
      end
    end

    context 'authorization request is successful' do
      let(:status) { 200 }
      let(:id_token) { 'id_token' }
      let(:response) { { id_token: id_token }.to_json }
      let(:decoded_token) { 'decoded_token' }

      it 'returns decoded authorized token' do
        allow(CsAuth::Apple).to receive(:decode_token).with(id_token).and_return(decoded_token)
        expect(CsAuth::Apple.authorized_token_for_code(auth_code, client_id)).to eq(decoded_token)
      end
    end
  end

  describe 'decode_token' do
    let(:identity_token) { 'identity_token' }

    context 'token cannot be decoded' do
      it 'raises InvalidTokenError' do
        allow(CsAuth::Apple).to receive(:jwk_set).and_return(jwk_set)
        allow(JSON::JWT).to receive(:decode).with(identity_token, jwk_set).and_raise(JSON::JWT::Exception)
        expect { CsAuth::Apple.decode_token(identity_token) }.to raise_error CsAuth::Apple::InvalidTokenError
      end
    end

    context 'token can be decoded' do
      let(:decoded_token) { 'decoded_token' }

      it 'returns decoded token' do
        allow(CsAuth::Apple).to receive(:jwk_set).and_return(jwk_set)
        allow(JSON::JWT).to receive(:decode).with(identity_token, jwk_set).and_return(decoded_token)
        expect(CsAuth::Apple.decode_token(identity_token)).to eq(decoded_token)
      end
    end
  end

  describe 'validate_decoded_token' do
    let(:decoded_token) { 'decoded_token' }
    let(:apple_user_id) { 'apple_user_id' }

    it 'validates all token fields' do
      expect(CsAuth::Apple).to receive(:validate_token_iss).with(decoded_token)
      expect(CsAuth::Apple).to receive(:validate_token_aud).with(decoded_token)
      expect(CsAuth::Apple).to receive(:validate_token_sub).with(decoded_token, apple_user_id)
      expect(CsAuth::Apple).to receive(:validate_token_exp).with(decoded_token)
      expect(CsAuth::Apple).to receive(:validate_token_iat).with(decoded_token)
      expect(CsAuth::Apple).to receive(:validate_token_email_present).with(decoded_token)
      expect(CsAuth::Apple).to receive(:validate_token_email_verified).with(decoded_token)
      expect(CsAuth::Apple.validate_decoded_token(decoded_token, apple_user_id)).to be true
    end
  end

  describe 'validate_token_iss' do
    let(:decoded_token) { { 'iss' => iss } }

    context 'iss is valid' do
      let(:iss) { 'https://appleid.apple.com' }
      it 'validates' do
        expect(CsAuth::Apple.validate_token_iss(decoded_token)).to be true
      end
    end

    context 'iss is invalid' do
      let(:iss) { 'bad' }
      it 'raises InvalidTokenError' do
        expect { CsAuth::Apple.validate_token_iss(decoded_token) }.to raise_error CsAuth::Apple::InvalidTokenError
      end
    end
  end

  describe 'validate_token_aud' do
    let(:decoded_token) { { 'aud' => aud} }

    context 'aud is joule app' do
      let(:aud) { 'com.chefsteps.circulator' }
      it 'validates' do
        expect(CsAuth::Apple.validate_token_aud(decoded_token)).to be true
      end
    end

    context 'aud is website' do
      let(:aud) { 'com.chefsteps.web' }
      it 'validates' do
        expect(CsAuth::Apple.validate_token_aud(decoded_token)).to be true
      end
    end

    context 'aud is invalid' do
      let(:aud) { 'bad' }
      it 'raises InvalidTokenError' do
        expect { CsAuth::Apple.validate_token_aud(decoded_token) }.to raise_error CsAuth::Apple::InvalidTokenError
      end
    end
  end

  describe 'validate_token_sub' do
    let(:apple_user_id) { 'apple_user_id' }
    let(:decoded_token) { { 'sub' => apple_user_id } }

    context 'sub matches user id' do
      it 'validates' do
        expect(CsAuth::Apple.validate_token_sub(decoded_token, apple_user_id)).to be true
      end
    end

    context 'sub does not match user id' do
      it 'raises InvalidTokenError' do
        expect { CsAuth::Apple.validate_token_sub(decoded_token, 'bad_user_id') }.to raise_error CsAuth::Apple::InvalidTokenError
      end
    end
  end

  describe 'validate_token_exp' do
    let(:decoded_token) { { 'exp' => exp } }

    context 'exp is in the future' do
      let(:exp) { (Time.now + 1.day).to_i }
      it 'validates' do
        expect(CsAuth::Apple.validate_token_exp(decoded_token)).to be true
      end
    end

    context 'exp is in the past' do
      let(:exp) { (Time.now - 1.day).to_i }
      it 'raises InvalidTokenError' do
        expect { CsAuth::Apple.validate_token_exp(decoded_token) }.to raise_error CsAuth::Apple::InvalidTokenError
      end
    end
  end

  describe 'validate_token_iat' do
    let(:decoded_token) { { 'iat' => iat } }

    context 'iat is within the last 5 minutes' do
      let(:iat) { (Time.now - 1.minute).to_i }
      it 'validates' do
        expect(CsAuth::Apple.validate_token_iat(decoded_token)).to be true
      end
    end

    context 'iat is older than 5 minutes' do
      let(:iat) { (Time.now - 6.minutes).to_i }
      it 'raises InvalidTokenError' do
        expect { CsAuth::Apple.validate_token_iat(decoded_token) }.to raise_error CsAuth::Apple::InvalidTokenError
      end
    end
  end

  describe 'validate_token_email_present' do
    let(:decoded_token) { { 'email' => email } }

    context 'email is present' do
      let(:email) { 'a@b.com' }
      it 'validates' do
        expect(CsAuth::Apple.validate_token_email_present(decoded_token)).to be true
      end
    end

    context 'email is blank' do
      let(:email) { nil }
      it 'raises InvalidTokenError' do
        expect { CsAuth::Apple.validate_token_email_present(decoded_token) }.to raise_error CsAuth::Apple::InvalidTokenError
      end
    end
  end

  describe 'validate_token_email_verified' do
    let(:decoded_token) { { 'email_verified' => email_verified } }

    context 'email is verified' do
      let(:email_verified) { 'true' }
      it 'validates' do
        expect(CsAuth::Apple.validate_token_email_verified(decoded_token)).to be true
      end
    end

    context 'email is not verified' do
      let(:email_verified) { 'false' }
      it 'raises InvalidTokenError' do
        expect { CsAuth::Apple.validate_token_email_verified(decoded_token) }.to raise_error CsAuth::Apple::InvalidTokenError
      end
    end
  end
end
