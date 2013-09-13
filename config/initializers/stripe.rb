if Rails.env.production?
  Rails.configuration.stripe = {
    publishable_key: 'pk_live_cApWBfWBJ4MGOBfl3Td0Jqo9',
    secret_key: 'sk_live_K7iopRayRpNFMSFUpihEIabR' 
  }
else
  Rails.configuration.stripe = {
    publishable_key: 'pk_test_0BuspZCCAn7jj1bpW2d1LG51',
    secret_key:  'sk_test_vbGt58BNlwRrgjEvq9QtYf0G'
  }
end

Stripe.api_key = Rails.configuration.stripe[:secret_key]