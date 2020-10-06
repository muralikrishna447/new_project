require 'cs_auth/apple'

# Initialize the fallback with a previously fetched key set.
jwks_json = JSON.parse(File.read(Rails.root.join('config/apple-auth-jwks.json')))
CsAuth::Apple.initialize_fallback_jwk_set(JSON::JWK::Set.new(jwks_json))
# Primes the cache with the live JWK set from apple.com
CsAuth::Apple.jwk_set unless Rails.env.test?
