class ReportsController < ApplicationController
  before_filter :ensure_admin

  def stripe
    if request.get?
      # stripe_csv = []
      csv_string = CSV.generate do |stripe_csv|
        stripe_csv << [
          "id", "object", "transaction created", "paid", "amount", "refunded", "card_id", "card_object", "last4", "card_type", "exp_month", "exp_year", "fingerprint", "customer", "country", "name", "address_line1", "address_line2", "address_city", "address_state", "address_zip", "address_country", "cvc_check", "address_line1_check", "address_zip_check", "captured", "balance_transaction", "failure_message", "failure_code", "amount_refunded", "refund_at", "refund_transaction", "customer", "invoice", "description", "dispute", "metadata", "sales_tax_paid?",
          "charge_gross", "charge_fees", "refund_gross", "refund_fees", "charge_count", "refund_count", "net"
        ]
        pages = Stripe::Charge.all(count: 1, created: {gte: (Time.now-1.month).beginning_of_month.to_i, lte: (Time.now-1.month).end_of_month.to_i})
        0.upto((pages.count/100)+1) do |x|
          Stripe::Charge.all(offset: x, count: 100, created: {gte: (Time.now-1.month).beginning_of_month.to_i, lte: (Time.now-1.month).end_of_month.to_i} ).each do |charge|
            stripe_csv << [
              charge["id"], charge["object"], Time.at(charge["created"]), charge["paid"], (charge["amount"].to_i/100), charge["refunded"], charge["card"]["id"], charge["card"]["object"], charge["card"]["last4"], charge["card"]["type"], charge["card"]["exp_month"], charge["card"]["exp_year"], charge["card"]["fingerprint"], charge["card"]["customer"], charge["card"]["country"], charge["card"]["name"], charge["card"]["address_line1"], charge["card"]["address_line2"], charge["card"]["address_city"], charge["card"]["address_state"], charge["card"]["address_zip"], charge["card"]["address_country"], charge["card"]["cvc_check"], charge["card"]["address_line1_check"], charge["card"]["address_cip_check"], charge["captured"], charge["balance_transaction"], charge["failure_message"], charge["failure_code"], charge["amount_refunded"], (charge["refunds"].first.present? ? Time.at(charge["refunds"].first["created"]) : nil), (charge["refunds"].first.present? ? charge["refunds"].first["balance_transaction"] : nil), charge["customer"], charge["invoice"], charge["description"], charge["dispute"], charge["metadata"], charge["description"].include?("WA state").to_s
            ]
          end
        end
        Stripe::Transfer.all(count: 100, date: {gte: (Time.now-1.month).beginning_of_month.to_i, lte: (Time.now-1.month).end_of_month.to_i}).each do |transfer|
          stripe_csv << [
            transfer["id"], transfer["object"], Time.at(transfer["date"]), nil, (transfer["amount"].to_i/100), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            transfer["summary"]["charge_gross"], transfer["summary"]["charge_fees"], transfer["summary"]["refund_gross"], transfer["summary"]["refund_fees"], transfer["summary"]["charge_count"], transfer["summary"]["refund_count"], transfer["summary"]["net"]
          ]
        end
      end
      # render(text: stripe_csv)
      send_data(csv_string, :type => 'text/csv; charset=utf-8; header=present', :filename => "stripe-report-#{Time.now.beginning_of_month}-#{Time.now.end_of_month}")
      # render(text: csv_string)
    else

    end
  end

  private
  def ensure_admin
    redirect_to root_url unless current_user && current_user.role?(:admin)
  end

end