require 'csv'
require 'optparse'
require 'date'
require 'pry'
require './shipping'

#
# Takes a CSV from the output of the 'validate_shopify_orders' script and
# sorts it (in FIFO order of placement).
#
# The output of this script is the sorted CSV input.
#
# Options:
#   --input: A CSV input file in the Shopify export schema.
#   --priority: Optional file of priority order IDs to bump to the top.
#   --blacklist: Optional file of blacklisted order IDs to filter out.
#   --quantity: Optional limit on the quantity of items included in the output.
#

# Options parsing
options = {}
option_parser = OptionParser.new do |option|
  option.on('-i', '--input INPUT_FILE', 'CSV export file of validated Shopify orders') do |file|
    options[:input_file] = file
  end

  option.on('-p', '--priority PRIORITY_FILE', 'Optional CSV file of priority order IDs') do |file|
    options[:priority_file] = file
  end

  option.on('-b', '--blacklist BLACKLIST_FILE', 'Optional CSV file of blacklist order IDs') do |file|
    options[:blacklist_file] = file
  end

  option.on('-l', '--quantity QUANTITY', 'Optional limit on the quantity of items included in the output') do |quantity|
    options[:quantity] = quantity
  end
end

option_parser.parse!
raise '--input is required' unless options[:input_file]
if options[:quantity]
  STDERR.puts "NOTE: --quantity was specified, limiting output to max quantity of #{options[:quantity]}"
end

order_rows = []
CSV.foreach(options[:input_file], headers: true) do |input_row|
  input_row['processed_at'] = DateTime.parse(input_row['processed_at'])
  order_rows << input_row
end

priority_order_ids = {}
if options[:priority_file]
  priority_index = 1
  CSV.foreach(options[:priority_file], headers: false) do |priority_row|
    order_id = priority_row[0]
    STDERR.puts "Prioritizing order with id #{order_id} with index #{priority_index}"
    priority_order_ids[priority_row[0]] = priority_index
    priority_index += 1
  end
end

blacklist_order_ids = {}
if options[:blacklist_file]
  CSV.foreach(options[:blacklist_file], headers: false) do |blacklist_row|
    blacklist_order_ids[blacklist_row[0]] = true
  end
end

order_rows.sort! do |x, y|
  # Default sort order is by processing timestamp, ascending
  val = x['processed_at'] <=> y['processed_at']

  # Special handling for priority orders
  x_has_priority = !priority_order_ids[x['id']].nil?
  y_has_priority = !priority_order_ids[y['id']].nil?
  if x_has_priority && y_has_priority
    # When comparing two priority orders, the one with the lower index wins
    val = priority_order_ids[x['id']] <=> priority_order_ids[y['id']]
  elsif x_has_priority && !y_has_priority
    val = -1
  elsif !x_has_priority && y_has_priority
    val = 1
  end
  val
end

order_count = 0
quantity_processed = 0
max_quantity = options[:quantity].to_i if options[:quantity]
output_str = CSV.generate(force_quotes: true) do |output_rows|
  output_rows << Shipping::SHOPIFY_EXPORT_SCHEMA_WITH_PRIORITY
  order_rows.each do |row|
    break if quantity_processed == max_quantity

    # We want to ship all the inventory we have available at any given time,
    # so we'll skip an order if it has quantity > 1 and we don't have enough
    # inventory to ship it today.
    current_quantity = row['quantity'].to_i
    next if (quantity_processed + current_quantity) > max_quantity

    if blacklist_order_ids[row['id']]
      STDERR.puts "Order with id #{row['id']} was blacklisted, filterting it out"
    else
      order_count += 1
      quantity_processed += current_quantity
      row['priority_index'] = order_count
      output_rows << row
    end
  end
end

puts output_str

STDERR.puts "Sorted #{order_rows.length} orders, output includes #{order_count} orders with total quantity #{quantity_processed}"
