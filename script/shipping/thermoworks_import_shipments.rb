require 'csv'
require 'optparse'
require 'shopify_api'
require_relative './rails_shim'
require_relative './config'

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
