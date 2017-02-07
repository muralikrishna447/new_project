require './rails_shim'
require 'csv'

options = {}
option_parser = OptionParser.new do |option|
  option.on('-i', '--input INPUT', 'Input file') do |input|
    options[:input] = input
  end
  option.on('-p', '--pickup-time PICKUP_TIME', 'Pickup time') do |pickup_time|
    options[:pickup_time] = pickup_time
  end
end
option_parser.parse!
raise '--input is required' unless options[:input]
raise '--pickup-time is required ' unless options[:pickup_time]

rows_in_pickup_time = []
CSV.foreach(options[:input], headers: true) do |row|
  rows_in_pickup_time << row if row['Pickup Time'] == options[:pickup_time]
end
Rails.logger.debug("Found #{rows_in_pickup_time.length} line items for pickup time #{options[:pickup_time]}")

summary_by_sku = {}
rows_in_pickup_time.each do |row|
  sku = row['Product SKU']
  if summary_by_sku[sku]
    summary_by_sku[sku][:quantity] += row['Quantity'].to_i
    summary_by_sku[sku][:total] += row['Line Item Total'].to_f
  else
    summary_by_sku[sku] = {
      name: row['Product Name'],
      quantity: row['Quantity'].to_i,
      total: row['Line Item Total'].to_f
    }
  end
end

output_str = CSV.generate(force_quotes: true) do |output|
  output << [
    'Product Name',
    'Product SKU',
    'Quantity',
    'Unit Price',
    'Total'
  ]

  grand_total = 0.0
  summary_by_sku.each do |sku, summary|
    output << [
      summary[:name],
      sku,
      summary[:quantity],
      summary[:total] / summary[:quantity],
      summary[:total]
    ]
    grand_total += summary[:total]
  end
  output << ['', '', '', '', grand_total]
end
puts output_str
