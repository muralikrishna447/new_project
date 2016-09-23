require 'csv'
require 'optparse'
require 'pry'
require './shipping'

#
# Filter the Shopify order export by tags on the order. The output format
# is exactly the same as the input, with filtered orders excluded.
#
# Options:
#   --tags: Comma-separated list of tags. Orders with any of the tags will be
#           filtered from the output.
#

# Options parsing
options = {}
option_parser = OptionParser.new do |option|
  option.on('-i', '--input INPUT_FILE', 'Input file') do |input|
    options[:input] = input
  end

  option.on('-t', '--tags TAGS', 'Shopify tags to filter orders on') do |tags|
    options[:tags] = tags
  end
end
option_parser.parse!

raise '--input is required' unless options[:input]

tags_to_filter = []
tags_to_filter = options[:tags].split(',').each(&:strip!) if options[:tags]

STDERR.puts "Filtering orders with tags: #{tags_to_filter}"

filtered_rows = []
filtered_order_count = 0
CSV.foreach(options[:input], headers: true) do |input_row|
  order_tags = input_row['tags'].split(',').each(&:strip!)
  # Check for intersection of order tags and tags to filter
  if (order_tags & tags_to_filter).empty?
    filtered_rows << input_row
  else
    filtered_order_count += 1
    STDERR.puts "Order with id #{input_row['id']} has filtered tag(s), filtering it"
  end
end

output_str = CSV.generate(force_quotes: true) do |output_rows|
  output_rows << Shipping::SHOPIFY_EXPORT_SCHEMA
  filtered_rows.each { |row| output_rows << row }
end

puts output_str

STDERR.puts "Passed through #{filtered_rows.length} orders, filtered out #{filtered_order_count} orders"
