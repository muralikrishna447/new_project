require 'csv'
require 'optparse'
require 'shopify_api'
require 'logger'
require_relative './rails_shim'
require_relative './config'

options = {}
option_parser = OptionParser.new do |option|
  option.on('-e', '--env ENV', 'environment') do |env|
    options[:env] = env
  end

  option.on('-d', '--date STORE', 'date, YYYY-MM-DD') do |date_str|
    options[:date] = Date.parse(date_str)
  end
end
option_parser.parse!
options[:date] ||= Date.today
conf = get_config(options[:env])
setup_shopify(conf)

# NOTE: would normally use UTC to avoid daylight savings time issues.
# However, this Thermoworks deal is only valid for a few weeks and
# won't overlap any daylight savings.  In terms of our workflow with
# Thermoworks, I think it's better to deal in local Seattle time
pst_offset = '-8'

d = options[:date]
start_date = DateTime.new(d.year, d.month, d.day, 0, 0, 0, pst_offset)
end_date = start_date + 1.day

Rails.logger.info "Running Thermoworks export for #{d}"
params = {
  open_fulfillment: false,
  storage: 'file',
  quantity: 512,
  date: d,
  search_params: {
    created_at_min: "#{start_date}",
    created_at_max: "#{end_date}",
  }
}

Fulfillment::ThermoworksOrderExporter.perform(params)
