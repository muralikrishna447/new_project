require 'csv'
require 'set'
require 'optparse'
require 'bigdecimal'

# Takes a file containing user IDs with Premium and a Chargebee invoices file,
# then filters the invoices to contain only purchases made by Premium members.
# Calculates refund amount including tax and outputs results as CSV.

# The amount to refund, excluding tax
REFUND_AMOUNT = BigDecimal.new('39.0')

options = {}
option_parser = OptionParser.new do |option|
  option.on('-p', '--premium PREMIUM_USERS_FILE', 'Users with Premium file') do |premium_users_file|
    options[:premium_users_file] = premium_users_file
  end

  option.on('-i', '--invoices INVOICES_FILE', 'Chargebee invoices file') do |invoices_file|
    options[:invoices_file] = invoices_file
  end  
end
option_parser.parse!
raise '--premium is required' unless options[:premium_users_file]
raise '--invoices is required' unless options[:invoices_file]

# Build up the set of Premium user IDs
premium_user_ids = Set.new
CSV.foreach(options[:premium_users_file], headers: true) do |row|
  premium_user_ids.add(row['id'])
end

# Process the invoices file, filtering non-Premium members and calculating
# the amount to refund as we go.
refunds = []
CSV.foreach(options[:invoices_file], headers: true) do |row|
  user_id = row['Customer Id']
  invoice_number = row['Invoice Number']
  if premium_user_ids.include?(user_id)
    STDERR.puts("User ID #{user_id} is premium, adding to output")

    amount_including_tax = BigDecimal.new(row['Amount'])
    tax_total = BigDecimal.new(row['Tax Total'])
    # Calculate tax rate based on total amount and tax total.
    tax_rate = tax_total / (amount_including_tax - tax_total)
    # The tax rate will be innacurate b/c the tax total will have already been
    # rounded. We want to maintain precision until the end of the calculation
    # and then round up to two decimal points in the customer's favor.
    amount_to_refund = (REFUND_AMOUNT * (tax_rate + BigDecimal.new('1.0'))).round(2, BigDecimal::ROUND_UP)
    
    refunds << {
      invoice_number: invoice_number,
      user_id: user_id,
      amount_including_tax: amount_including_tax,
      tax_total: tax_total,
      tax_rate: tax_rate,
      amount_to_refund: amount_to_refund
    }
  else
    STDERR.puts("User ID #{user_id} is NOT premium, not adding to output")
  end
end

STDERR.puts("Creating refund output for #{refunds.length} customers")
csv_str = CSV.generate do |csv|
  csv << ['invoice_number', 'user_id', 'amount_including_tax', 'tax_total', 'tax_rate', 'amount_to_refund']
  refunds.each do |refund|
    csv << [
      refund[:invoice_number],
      refund[:user_id],
      refund[:amount_including_tax].to_s('F'),
      refund[:tax_total].to_s('F'),
      refund[:tax_rate].to_s('F'),
      refund[:amount_to_refund].to_s('F')
    ]
  end
end

puts csv_str
