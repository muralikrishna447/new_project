if Rails.env.production? || Rails.env.staging? || Rails.env.staging2?
  Rails.configuration.stripe = {
    publishable_key: ENV["STRIPE_KEY"],
    secret_key: ENV["STRIPE_SECRET"]
  }
else
  Rails.configuration.stripe = {
    publishable_key: 'pk_live_b1CQV9HfmNE8djLHCKpykTxc',
    secret_key:  'sk_live_WAwZz56nyVf1OAH2D6uCMmfK'
  }
end

Stripe.api_key = Rails.configuration.stripe[:secret_key]
