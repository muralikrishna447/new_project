require 'csv'
require 'optparse'
require 'bigdecimal'
require 'chargebee'

# Takes a CSV file of invoice and refund amounts and issues them using Chargebee API.

options = {}
option_parser = OptionParser.new do |option|
  option.on('-r', '--refunds REFUNDS_FILE', 'Refunds file') do |refunds_file|
    options[:refunds_file] = refunds_file
  end

  option.on('-s', '--site CHARGEBEE_SITE', 'Chargebee site') do |site|
    options[:site] = site
  end  

  option.on('-a', '--api-key CHARGEBEE_API_KEY', 'Chargebee API key') do |api_key|
    options[:api_key] = api_key
  end

  option.on('-e', '--enforce-single-refund', 'Enforce single refund') do |enforce_single_refund|
    options[:enforce_single_refund] = true
  end

  option.on('-c', '--comment COMMENT', 'Refund comment') do |comment|
    options[:comment] = comment
  end

  option.on('-d', '--dry-run', 'Dry run') do
    options[:dry_run] = true
  end
end
option_parser.parse!
raise '--refunds is required' unless options[:refunds_file]
raise '--site is required' unless options[:site]
raise '--api-key is required' unless options[:api_key]
raise '--comment is required' unless options[:comment]

ChargeBee.configure(
  site: options[:site],
  api_key: options[:api_key]
)

refunds = []
CSV.foreach(options[:refunds_file], headers: true) do |row|
  invoice_number = row['invoice_number']
  user_id = row['user_id']
  amount_to_refund = BigDecimal.new(row['amount_to_refund'])
  refunds << {
    invoice_number: invoice_number,
    user_id: user_id,
    amount_to_refund: amount_to_refund
  }
end

STDERR.puts "Attempting to refund #{refunds.length} invoices"

refunds.each do |refund|
  if options[:enforce_single_refund]
    # See if any credit notes exist, indicating a refund has already been performed
    credit_notes = ChargeBee::CreditNote.list('reference_invoice_id[is]' => refund[:invoice_number])
    if credit_notes.length > 0
      STDERR.puts "Invoice number #{refund[:invoice_number]} for user ID #{refund[:user_id]} has credit notes, skipping"
      next
    end
  end

  # We expect the amount to refund to be already rounded to two digits.
  # Chargebee expects the amount as cents (integer).
  chargebee_amount_to_refund = (refund[:amount_to_refund] * BigDecimal.new('100')).to_i

  STDERR.puts "Refunding invoice number #{refund[:invoice_number]} for user ID #{refund[:user_id]} with amount #{chargebee_amount_to_refund}"
  
  next if options[:dry_run]

  response = ChargeBee::Invoice.refund(
    refund[:invoice_number],
    refund_amount: chargebee_amount_to_refund,
    comment: options[:comment],
    customer_notes: options[:comment],
    credit_note: { reason_code: 'other' }
  )
  if response.transaction.amount != chargebee_amount_to_refund
    raise "Refund response for invoice number #{refund[:invoice_number]} for user ID #{refund[:user_id]} was #{response.transaction.amount}, expected #{chargebee_amount_to_refund}"
  end

  STDERR.puts "Refunded invoice number #{refund[:invoice_number]} for user ID #{refund[:user_id]} with amount #{chargebee_amount_to_refund}"
end
