if Rails.env.production? || Rails.env.staging? || Rails.env.staging2?
  Rails.configuration.stripe = {
    publishable_key: ENV["STRIPE_KEY"],
    secret_key: ENV["STRIPE_SECRET"]
  }
else
  Rails.configuration.stripe = {
    publishable_key: 'pk_test_0BuspZCCAn7jj1bpW2d1LG51',
    secret_key:  'sk_test_vbGt58BNlwRrgjEvq9QtYf0G'
  }
end

Stripe.api_key = Rails.configuration.stripe[:secret_key]
