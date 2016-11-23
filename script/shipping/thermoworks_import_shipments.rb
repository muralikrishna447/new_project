require 'csv'
require 'optparse'
require 'shopify_api'
require_relative './rails_shim'

def get_config(env)
  conf = {
    'staging' => {
      shopify_key: ENV['SHOPIFY_API_KEY'],
      shopify_pass: ENV['SHOPIFY_PASSWORD'],
      shopify_store: 'chefsteps-staging',
    }
  }[env]
  raise "No config for environment: #{env}" unless conf
  return conf
end

def setup_shopify(conf)
  raise "No API key provided" unless conf[:shopify_key]
  raise "No API password provided" unless conf[:shopify_pass]
  raise "No Shopify store provided" unless conf[:shopify_store]
  ShopifyAPI::Base.site = "https://#{conf[:shopify_key]}:#{conf[:shopify_pass]}" \
                          "@#{conf[:shopify_store]}.myshopify.com/admin"
end

options = {}
option_parser = OptionParser.new do |option|
  option.on('-e', '--env ENV', 'environment') do |env|
    options[:env] = env
  end

  option.on('-i', '--input INPUT', 'Input file') do |input|
    options[:input] = input
  end
end
option_parser.parse!
conf = get_config(options[:env])
setup_shopify(conf)

Fulfillment::ThermoworksShipmentImporter.perform(
  complete_fulfillment: true,
  storage: 'file',
  storage_filename: options[:input]
)
