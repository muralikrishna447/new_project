class ReportGenerator
  @queue = :report_generator
  def self.perform(type, user_id, start_date=nil, end_date=nil)
    case type
    when "stripe"
      user = User.find(user_id)
      stripe_data = StripeReport.quickbooks_report(start_date, end_date)
      f = File.new("tmp/stripe_data_export.csv", 'wb')
      f.puts stripe_data
      f.close
      ReportMailer.send_report_file(user.email, 'stripe_data', 'here is the stripe data', "quickbooks-file-#{start_date}-#{end_date}.tsv", stripe_data).deliver
    when "sales"
    end
  end
end
