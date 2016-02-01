require "openssl"
require "base64"
require "time"
require "json"

if Rails.env.production?
  Rails.configuration.shopify = {
    store_domain: 'delve.myshopify.com',
    api_key: ENV["SHOPIFY_KEY"],
    password: ENV["SHOPIFY_SECRET"],
    multipass_secret: ENV["SHOPIFY_MULTIPASS_SECRET"]
  }
elsif Rails.env.staging? || Rails.env.staging2?
  Rails.configuration.shopify = {
    store_domain: 'chefsteps-staging.myshopify.com',
    api_key: ENV["SHOPIFY_KEY"],
    password: ENV["SHOPIFY_SECRET"],
    multipass_secret: ENV["SHOPIFY_MULTIPASS_SECRET"]
  }
elsif Rails.env.test?
  Rails.configuration.shopify = {
    store_domain: 'chefsteps-staging.myshopify.com',
    api_key: '123',
    password:  '321',
    multipass_secret: "abc"
  }
else
  Rails.configuration.shopify = {
    store_domain: 'chefsteps-staging.myshopify.com',
    api_key: 'f3c79828c0f50b04866481389eacb2d2',
    password:  '5553e01d45c426ced082e9846ad56eee',
    multipass_secret: '905c5b3b3ad7804d28e8a33e6a247eca'
  }
end
ShopifyAPI::Base.site = "https://#{Rails.configuration.shopify[:api_key]}:#{Rails.configuration.shopify[:password]}@#{Rails.configuration.shopify[:store_domain]}/admin"
