require 'csv'
require 'optparse'
require 'pry'

#
# Takes barcodes scanned before shipment and a shipment CSV export from
# ShipStation and verifies that we didn't miss any orders.
#
# The output is CSV file containing the verification status for each order.
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
  barcode.strip!
  tracking = nil
  if barcode.length == 34
    # For FedEx Express/Ground services, the barcode is 34 characters
    # and the tracking number is the last 12.
    tracking = barcode[-12, 12]
  elsif barcode.length == 30
    # For FedEx SmartPost, the barcode is 30 characters
    # and the tracking number is the last 20.
    tracking = barcode[-20, 20]
  else
    raise "Barcode does not have expected length: #{barcode}"
  end
  scanned_trackings[tracking] = true if tracking
end
STDERR.puts "Found #{scanned_trackings.length} unique barcodes"

total_packages = 0
total_orders = 0
orders = []
all_found = true
CSV.foreach(options[:shipments], headers: true) do |shipment|
  order_number = shipment['Order - Number']
  tracking = shipment['Shipment - Tracking Number']

  # Verify that we scanned a tracking number for what we thought we shipped
  status = 'found'
  if scanned_trackings[tracking]
    STDERR.puts "Success: looks like you shipped order number #{order_number} with tracking number #{tracking}"
  else
    all_found = false
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
if all_found
  STDERR.puts "SUCCESS: Checked #{total_orders} orders and found #{total_packages} corresponding scanned packages"
else
  STDERR.puts "FAILED: Checked #{total_orders} orders and found #{total_packages} packages, but not all expected tracking numbers were found"
end

# Verify that the number of unique tracking numbers that we scanned matches
# our expected package count. For orders with quantity > 1, only the master
# tracking number will show up in the shipments export, but we should have
# scanned all non-master tracking numbers. If any of the non-master tracking
# numbers were not scanned, the expected package count won't match the number
# of barcodes scanned.
if total_packages != scanned_trackings.length
  STDERR.puts "DANGER!!! We expected #{total_packages} packages, but we scanned #{scanned_trackings.length} tracking numbers"
end

output_str = CSV.generate(force_quotes: true) do |output_rows|
  output_rows << ['order_number', 'tracking_number', 'status']
  orders.each { |order| output_rows << order }
end
puts output_str
