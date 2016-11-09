require 'csv'
require 'optparse'
require 'shopify_api'
require 'logger'
require_relative './rails_shim'

options = {}
option_parser = OptionParser.new do |option|
  option.on('-k', '--key API_KEY', 'Shopify API key') do |api_key|
    options[:api_key] = api_key
  end

  option.on('-p', '--password PASSWORD', 'Shopify password') do |password|
    options[:password] = password
  end

  option.on('-d', '--date STORE', 'date, YYYY-MM-DD') do |date_str|
    options[:date] = Date.parse(date_str)
  end
end
option_parser.parse!
options[:api_key] ||= 'f3c79828c0f50b04866481389eacb2d2'
options[:password] ||= '5553e01d45c426ced082e9846ad56eee'
options[:store] ||= 'chefsteps-staging'
options[:date] ||= Date.today

raise '--key is required' unless options[:api_key]
raise '--password is required' unless options[:password]
raise '--store is required' unless options[:store]
ShopifyAPI::Base.site = "https://#{options[:api_key]}:#{options[:password]}@#{options[:store]}.myshopify.com/admin"

pst_offset = '-8'
d = options[:date]
start_date = DateTime.new(d.year, d.month, d.day, 0, 0, 0, pst_offset)
end_date = start_date + 1.day

params = {
  open_fulfillment: false,
  storage: 'file',
  quantity: 512,
  search_params: {
    created_at_min: "#{start_date}",
    created_at_max: "#{end_date}",
  }
}

Fulfillment::ThermoworksOrderExporter.perform(params)
