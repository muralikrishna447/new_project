require 'csv'
require 'optparse'
require 'pry'

#
# Takes a CSV from the output of the 'validate_shopify_orders' script and
# sorts it (in FIFO order of placement).
#
# The output of this script is the sorted CSV input.
#
# Options:
#   --barcodes: A text file containing scanned tracking numbers, one per line
#   --shipments: Shipments exported from ShipStation as CSV
#

# Options parsing
options = {}
option_parser = OptionParser.new do |option|
  option.on('-b', '--barcodes BARCODES_FILE', 'Text file containing scanned tracking barcodes of shipped orders') do |file|
    options[:barcodes] = file
  end

  option.on('-s', '--shipments SHIPMENTS_EXPORT_FILE', 'Shipments exported from ShipStation as CSV') do |file|
    options[:shipments] = file
  end
end

option_parser.parse!
raise '--barcodes is required' unless options[:barcodes]
raise '--shipments is required' unless options[:shipments]

scanned_trackings = {}
File.readlines(options[:barcodes]).each do |barcode|
  # The tracking number is the last 12 digits of the barcode
  tracking = barcode.strip[-12, 12]
  scanned_trackings[tracking] = true
end
STDERR.puts "Found #{scanned_trackings.length} unique barcodes"

total_packages = 0
total_orders = 0
orders = []
CSV.foreach(options[:shipments], headers: true) do |shipment|
  order_number = shipment['Order - Number']
  tracking = shipment['Shipment - Tracking Number']

  # Verify that we scanned a tracking number for what we thought we shipped
  status = 'found'
  if scanned_trackings[tracking]
    STDERR.puts "Success: looks like you shipped order number #{order_number} with tracking number #{tracking}"
  else
    status = 'missing'
    STDERR.puts "DANGER!!! Order number #{order_number} was not scanned, expected tracking number #{tracking}"
  end

  orders << [
    order_number,
    tracking,
    status
  ]

  total_packages += shipment['Shipment - Package Count'].to_i
  total_orders += 1
end
STDERR.puts "Checked #{total_orders} orders and verified #{total_packages} packages"

# Verify that the number of unique tracking numbers that we scanned matches
# our expected package count. For orders with quantity > 1, only the master
# tracking number will show up in the shipments export, but we should have
# scanned all non-master tracking numbers. If any of the non-master tracking
# numbers were not scanned, the expected package count won't match the number
# of barcodes scanned.
if total_packages != scanned_trackings.length
  puts "DANGER!!! We should have shipped #{total_packages} packages, but we only scanned #{scanned_trackings.length} tracking numbers"
end

output_str = CSV.generate(force_quotes: true) do |output_rows|
  output_rows << ['order_number', 'tracking_number', 'status']
  orders.each { |order| output_rows << order }
end
puts output_str
