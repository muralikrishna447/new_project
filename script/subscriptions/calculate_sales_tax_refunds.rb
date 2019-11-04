require 'csv'
require 'optparse'
require 'bigdecimal'
require 'chargebee'

# Takes a Chargebee invoices file and reads in the total tax amount paid.
# Then looks up credit notes to see if any credit notes including tax
# have been refunded, and calculates remaining tax amount to refund.

options = {}
option_parser = OptionParser.new do |option|
  option.on('-i', '--invoices INVOICES_FILE', 'Chargebee invoices file') do |invoices_file|
    options[:invoices_file] = invoices_file
  end

  option.on('-s', '--site CHARGEBEE_SITE', 'Chargebee site') do |site|
    options[:site] = site
  end  

  option.on('-a', '--api-key CHARGEBEE_API_KEY', 'Chargebee API key') do |api_key|
    options[:api_key] = api_key
  end
end
option_parser.parse!
raise '--invoices is required' unless options[:invoices_file]
raise '--site is required' unless options[:site]
raise '--api-key is required' unless options[:api_key]

ChargeBee.configure(
  site: options[:site],
  api_key: options[:api_key]
)

refunds = []
CSV.foreach(options[:invoices_file], headers: true) do |row|
  user_id = row['Customer Id']
  invoice_number = row['Invoice Number']
  billing_country = row['Customer Billing Country']
  tax_total = BigDecimal.new(row['Tax Total'])

  if billing_country == 'US'
    STDERR.puts "Invoice number #{invoice_number} has billing country US, ignoring"
    next
  end

  if tax_total.zero?
    STDERR.puts "Invoice number #{invoice_number} has billing country #{billing_country} but has zero tax, ignoring"
    next
  end

  # Handle partial refunds by calculating the sum of taxes refunded in all existing credit notes.
  credit_note_results = ChargeBee::CreditNote.list('reference_invoice_id[is]' => invoice_number)
  tax_already_refunded = BigDecimal.new(0)
  if credit_note_results.length > 0
    credit_note_results.each do |result|
      # Each credit note has a taxes array with tax line amounts as cents.
      # So we want to sum the tax lines and divide by 100 to get the dollar amount.
      tax_already_refunded += BigDecimal.new(result.credit_note.taxes.reduce(0) { |sum, tax_obj| sum + tax_obj.amount }) / BigDecimal.new(100)
    end
    STDERR.puts "Invoice number #{invoice_number} has existing refunded tax amount #{tax_already_refunded.to_s('F')}"
  end

  # Calculate the remaining tax amount to refund.
  # If zero, the purchase was fully refunded.
  amount_to_refund = tax_total - tax_already_refunded
  if amount_to_refund.zero?
    STDERR.puts "Invoice number #{invoice_number} has no tax left to refund, ignoring"
    next
  end

  STDERR.puts "Invoice number #{invoice_number} has billing country #{billing_country} and tax to refund #{amount_to_refund.to_s('F')}"
  refunds << {
    invoice_number: invoice_number,
    user_id: user_id,
    billing_country: billing_country,
    tax_total: tax_total,
    tax_already_refunded: tax_already_refunded,
    amount_to_refund: amount_to_refund
  }
end

STDERR.puts("Creating refund output for #{refunds.length} customers")
csv_str = CSV.generate do |csv|
  csv << ['invoice_number', 'user_id', 'billing_country', 'tax_total', 'tax_already_refunded', 'amount_to_refund']
  refunds.each do |refund|
    csv << [
      refund[:invoice_number],
      refund[:user_id],
      refund[:billing_country],
      refund[:tax_total].to_s('F'),
      refund[:tax_already_refunded].to_s('F'),
      refund[:amount_to_refund].to_s('F')
    ]
  end
end

puts csv_str