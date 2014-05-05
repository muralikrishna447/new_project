class ReportsController < ApplicationController
  before_filter :ensure_admin

  # def stripe
  #   @transaction_fee = 0.3
  #   @per_transaction_percent = 0.029
  #   @sales_tax = 1.095
  #   if request.get?
  #     previous_month = (Time.now-1.month)
  #     # stripe_csv = []
  #     csv_string = CSV.generate do |stripe_csv|
  #       stripe_csv << [
  #         "id", "object", "transaction created", "paid", "amount", "refunded", "card_id", "card_object", "last4", "card_type", "exp_month", "exp_year", "fingerprint", "customer", "country", "name", "address_line1", "address_line2", "address_city", "address_state", "address_zip", "address_country", "cvc_check", "address_line1_check", "address_zip_check", "captured", "balance_transaction", "failure_message", "failure_code", "amount_refunded", "refund_at", "refund_transaction", "customer", "invoice", "description", "dispute", "metadata", "sales_tax_paid?",
  #         # Calculated
  #         "stripe fee", "sales tax", "revenue", "total deposit", "refund fee", "refund tax", "refund revenue", "total refund",
  #         # Transfer
  #         "charge_gross", "charge_fees", "refund_gross", "refund_fees", "charge_count", "refund_count", "net"
  #       ]
  #       pages = Stripe::Charge.all(count: 1, created: {gte: previous_month.beginning_of_month.to_i, lte: previous_month.end_of_month.to_i})
  #       0.upto((pages.count/100)+1) do |x|
  #         Stripe::Charge.all(offset: x*100, count: 100, created: {gte: previous_month.beginning_of_month.to_i, lte: previous_month.end_of_month.to_i} ).each do |charge|
  #           next unless charge["paid"]
  #           charge_amount = (charge["amount"].to_i/100.00)
  #           stripe_csv << [
  #             charge["id"], charge["object"], Time.at(charge["created"]), charge["paid"], charge_amount, charge["refunded"], charge["card"]["id"], charge["card"]["object"], charge["card"]["last4"], charge["card"]["type"], charge["card"]["exp_month"], charge["card"]["exp_year"], charge["card"]["fingerprint"], charge["card"]["customer"], charge["card"]["country"], charge["card"]["name"], charge["card"]["address_line1"], charge["card"]["address_line2"], charge["card"]["address_city"], charge["card"]["address_state"], charge["card"]["address_zip"], charge["card"]["address_country"], charge["card"]["cvc_check"], charge["card"]["address_line1_check"], charge["card"]["address_cip_check"], charge["captured"], charge["balance_transaction"], charge["failure_message"], charge["failure_code"], (charge["amount_refunded"].to_i/100.00), (charge["refunds"].first.present? ? Time.at(charge["refunds"].first["created"]) : nil), (charge["refunds"].first.present? ? charge["refunds"].first["balance_transaction"] : nil), charge["customer"], charge["invoice"], charge["description"], charge["dispute"], charge["metadata"], charge["description"].include?("WA state").to_s,
  #             stripe_fee(charge), sales_tax(charge), revenue(charge), total_deposit(charge), refund_fee(charge), refund_tax(charge), refund_revenue(charge), total_refund(charge) # calculated
  #           ]
  #         end
  #       end

  #       old_pages = Stripe::Charge.all(count: 1, :refunded => true, created: {gte: (previous_month-1.month).beginning_of_month.to_i, lte: (previous_month-1.month).end_of_month.to_i})
  #       0.upto((pages.count/100)+1) do |x|
  #         Stripe::Charge.all(offset: x*100, count: 100, :refunded => true, created: {gte: (previous_month-1.month).beginning_of_month.to_i, lte: (previous_month-1.month).end_of_month.to_i} ).each do |charge|
  #           if charge["refunded"]
  #             refund_at = Time.at(charge["refunds"].first["created"])
  #             if refund_at.between?(previous_month.beginning_of_month, previous_month.end_of_month)
  #               charge_amount = (charge["amount"].to_i/100.00)
  #               stripe_csv << [
  #                 charge["id"], charge["object"], Time.at(charge["created"]), charge["paid"], (charge["amount"].to_i/100.00), charge["refunded"], charge["card"]["id"], charge["card"]["object"], charge["card"]["last4"], charge["card"]["type"], charge["card"]["exp_month"], charge["card"]["exp_year"], charge["card"]["fingerprint"], charge["card"]["customer"], charge["card"]["country"], charge["card"]["name"], charge["card"]["address_line1"], charge["card"]["address_line2"], charge["card"]["address_city"], charge["card"]["address_state"], charge["card"]["address_zip"], charge["card"]["address_country"], charge["card"]["cvc_check"], charge["card"]["address_line1_check"], charge["card"]["address_cip_check"], charge["captured"], charge["balance_transaction"], charge["failure_message"], charge["failure_code"], (charge["amount_refunded"].to_i/100.00), (charge["refunds"].first.present? ? Time.at(charge["refunds"].first["created"]) : nil), (charge["refunds"].first.present? ? charge["refunds"].first["balance_transaction"] : nil), charge["customer"], charge["invoice"], charge["description"], charge["dispute"], charge["metadata"], charge["description"].include?("WA state").to_s,
  #                 stripe_fee(charge), sales_tax(charge), revenue(charge), total_deposit(charge), refund_fee(charge), refund_tax(charge), refund_revenue(charge), total_refund(charge)# Calculated
  #               ]
  #             end
  #           end
  #         end
  #       end

  #       Stripe::Transfer.all(count: 100, date: {gte: previous_month.beginning_of_month.to_i, lte: previous_month.end_of_month.to_i}).each do |transfer|
  #         stripe_csv << [
  #           transfer["id"], transfer["object"], Time.at(transfer["date"]), nil, (transfer["amount"].to_i/100.00), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
  #           # calculated
  #           nil, nil, nil, nil, nil, nil, nil, nil,
  #           (transfer["summary"]["charge_gross"].to_i/100.00), (transfer["summary"]["charge_fees"].to_i/100.00), (transfer["summary"]["refund_gross"].to_i/100.00), (transfer["summary"]["refund_fees"].to_i/100.00), (transfer["summary"]["charge_count"].to_i), (transfer["summary"]["refund_count"].to_i), (transfer["summary"]["net"].to_i/100.00)
  #         ]
  #       end
  #     end
  #     # render(text: stripe_csv)
  #     send_data(csv_string, :type => 'text/csv; charset=utf-8; header=present', :filename => "stripe-report-#{previous_month.beginning_of_month}-#{previous_month.end_of_month}")
  #     # render(text: csv_string)
  #   else

  #   end
  # end

  def stripe
    start_time = (Time.now-1.month).beginning_of_month
    end_time = (Time.parse("30/04/2014")).end_of_month
    stripe_csv = generate_csv(start_time, end_time)

    # Check is for money going out
    # Deposit for money going in
    header = []
    transfers = []
    charges = []
    refunds = []
    header << ["!TRNS", "TRNSID", "TRNSTYPE", "DATE", "ACCNT", "NAME", "CLASS","AMOUNT", "MEMO"]
    header << ["!SPL","SPLID","TRNSTYPE","DATE","ACCNT","NAME","CLASS","AMOUNT","MEMO"]
    header << ["!ENDTRNS"]
    CSV.parse(stripe_csv, headers: true).each do |stripe_record|
      if stripe_record["object"] == "charge"
        if transaction_type(stripe_record) == "CHECK"
          refunds << ["TRNS", "1", transaction_type(stripe_record), Time.parse(stripe_record["refund_at"]).to_s(:slashes), "Stripe Account", nil, "ChefSteps", stripe_record["total_refund"], "Refund for refunded charge ID: #{stripe_record["id"]}"]
          refunds << ["SPL", "2", transaction_type(stripe_record), Time.parse(stripe_record["refund_at"]).to_s(:slashes), "Income from Operations:Retail Sales:Digital Sales:Digital Sales Returns", "Delve Online", "ChefSteps", stripe_record["refund_revenue"], "Refund of charge #{stripe_record["id"]}"]
          line_number = 3
          if stripe_record["sales_tax_paid?"] == "true"
            refunds << ["SPL", line_number, transaction_type(stripe_record), Time.parse(stripe_record["refund_at"]).to_s(:slashes), "Sales Tax Payable", "WA State Dept of Revenue", "ChefSteps", stripe_record["refund_tax"], "Sales Tax for charge ID: #{stripe_record["id"]}"]
            line_number += 1
          end
          refunds << ["SPL", line_number, transaction_type(stripe_record), Time.parse(stripe_record["refund_at"]).to_s(:slashes), "Credit Card Transaction Fees", "Stripe (Vendor)", "ChefSteps", stripe_record["refund_fee"], "Refund of fees for #{stripe_record["id"]}"]
          refunds << ["ENDTRNS"]

          if Time.parse(stripe_record["transaction_created"]).between?(start_time, end_time)
            charges << ["TRNS", "1", "DEPOSIT", Time.parse(stripe_record["transaction_created"]).to_s(:slashes), "Stripe Account", nil, "ChefSteps", stripe_record["total_deposit"], "Net for charge ID: #{stripe_record["id"]}"]
            charges << ["SPL", "2", "DEPOSIT", Time.parse(stripe_record["transaction_created"]).to_s(:slashes), "Income from Operations:Retail Sales:Digital Sales:#{deposit_type(stripe_record)}", "Delve Online", "ChefSteps", stripe_record["revenue"], "Charge ID: #{stripe_record["id"]}"]
            line_number = 3
            if stripe_record["sales_tax_paid?"] == "true"
              charges << ["SPL", line_number, "DEPOSIT", Time.parse(stripe_record["transaction_created"]).to_s(:slashes), "Sales Tax Payable", "WA State Dept of Revenue", "ChefSteps", stripe_record["sales_tax"], "Sales Tax for charge ID: #{stripe_record["id"]}"]
              line_number += 1
            end
            charges << ["SPL", line_number, "DEPOSIT", Time.parse(stripe_record["transaction_created"]).to_s(:slashes), "Credit Card Transaction Fees", "Stripe (Vendor)", "ChefSteps", stripe_record["stripe_fee"], "Fees for charge ID: #{stripe_record["id"]}"]
            charges << ["ENDTRNS"]
          end
        elsif transaction_type(stripe_record) == "DEPOSIT"
          charges << ["TRNS", "1", transaction_type(stripe_record), Time.parse(stripe_record["transaction_created"]).to_s(:slashes), "Stripe Account", nil, "ChefSteps", stripe_record["total_deposit"], "Net for charge ID: #{stripe_record["id"]}"]
          charges << ["SPL", "2", transaction_type(stripe_record), Time.parse(stripe_record["transaction_created"]).to_s(:slashes), "Income from Operations:Retail Sales:Digital Sales:#{deposit_type(stripe_record)}", "Delve Online", "ChefSteps", stripe_record["revenue"], "Charge ID: #{stripe_record["id"]}"]
          line_number = 3
          if stripe_record["sales_tax_paid?"] == "true"
            charges << ["SPL", line_number, transaction_type(stripe_record), Time.parse(stripe_record["transaction_created"]).to_s(:slashes), "Sales Tax Payable", "WA State Dept of Revenue", "ChefSteps", stripe_record["sales_tax"], "Sales Tax for charge ID: #{stripe_record["id"]}"]
            line_number += 1
          end
          charges << ["SPL", line_number, transaction_type(stripe_record), Time.parse(stripe_record["transaction_created"]).to_s(:slashes), "Credit Card Transaction Fees", "Stripe (Vendor)", "ChefSteps", stripe_record["stripe_fee"], "Fees for charge ID: #{stripe_record["id"]}"]
          charges << ["ENDTRNS"]
        end
      elsif stripe_record["object"] == "transfer"
        transfers << ["TRNS", "1", "DEPOSIT", Time.parse(stripe_record["transaction_created"]).to_s(:slashes), "Commerce BK checking 9541", nil, "ChefSteps", stripe_record["amount"], "Transfer from Stripe: #{stripe_record["id"]}"]
        transfers << ["SPL", "2", "DEPOSIT", Time.parse(stripe_record["transaction_created"]).to_s(:slashes), "Stripe Account", nil, "ChefSteps", "-#{stripe_record["amount"]}", "Transfer from Stripe: #{stripe_record["id"]}"]
        transfers << ["ENDTRNS"]
      end
    end

    document = header + refunds + charges + transfers
    tsv_string = CSV.generate(col_sep: "\t") do |tsv|
      document.each{|d| tsv << d }
    end

    send_data(tsv_string, :type => 'text/tsv; charset=utf-8; header=present', :filename => "quickbooks-file-#{start_time}-#{end_time}.tsv")
  end

  private
  def transaction_type(stripe_record)
    if stripe_record["refund_revenue"].to_f > 0
      "CHECK"
    else
      "DEPOSIT"
    end
  end

  def deposit_type(stripe_record)
    if stripe_record["description"].include?("Whipping Siphons")
      "Siphon"
    elsif stripe_record["description"].include?("French Macarons")
      "Macaron"
    elsif stripe_record["description"].include?("Tender Cuts") || stripe_record["description"].include?("Steak to Salmon")
      "Tender Cuts"
    end
  end

  def ensure_admin
    redirect_to root_url unless current_user && current_user.role?(:admin)
  end

  def stripe_fee(charge)
    charge_amount = (charge["amount"].to_i/100.00)
    (charge_amount*@per_transaction_percent+@transaction_fee).round(2)
  end

  def sales_tax(charge)
    charge_amount = (charge["amount"].to_i/100.00)
    if charge["description"].include?("WA state")
      -1*(charge_amount-(charge_amount/@sales_tax)).round(2)
    else
      0
    end
  end

  def revenue(charge)
    charge_amount = (charge["amount"].to_i/100.00)
    -1*(charge_amount + sales_tax(charge))
  end

  def total_deposit(charge)
    -1*(revenue(charge) + sales_tax(charge)) - stripe_fee(charge)
  end

  def refund_fee(charge)
    refund_at = (charge["refunds"].first.present? ? Time.at(charge["refunds"].first["created"]) : nil)
    charge_amount = (charge["amount"].to_i/100.00)
    refund_amount = (charge["amount_refunded"].to_i/100.00)
    if refund_at
      if charge_amount == refund_amount
        -1*((refund_amount*@per_transaction_percent+@transaction_fee).round(2))
      else
        -1*((refund_amount*@per_transaction_percent).round(2))
      end
    else
      0
    end
  end

  def refund_tax(charge)
    refund_at = (charge["refunds"].first.present? ? Time.at(charge["refunds"].first["created"]) : nil)
    sales_tax_paid = charge["description"].include?("WA state")
    refund_amount = (charge["amount_refunded"].to_i/100.00)
    if refund_at
      if sales_tax_paid
        (refund_amount-(refund_amount/@sales_tax)).round(2)
      else
        0
      end
    else
      0
    end
  end

  def refund_revenue(charge)
    refund_amount = (charge["amount_refunded"].to_i/100.00)
    refund_amount - refund_tax(charge)
  end

  def total_refund(charge)
    -1*(refund_revenue(charge) + refund_tax(charge)) - refund_fee(charge)
  end

  def generate_csv(start_time, end_time)
  @transaction_fee = 0.3
  @per_transaction_percent = 0.029
  @sales_tax = 1.095
    # previous_month = (Time.now-2.month)
    # stripe_csv = []
    csv_string = CSV.generate do |stripe_csv|
      stripe_csv << [
        "id", "object", "transaction_created", "paid", "amount", "refunded", "card_id", "card_object", "last4", "card_type", "exp_month", "exp_year", "fingerprint", "customer", "country", "name", "address_line1", "address_line2", "address_city", "address_state", "address_zip", "address_country", "cvc_check", "address_line1_check", "address_zip_check", "captured", "balance_transaction", "failure_message", "failure_code", "amount_refunded", "refund_at", "refund_transaction", "customer", "invoice", "description", "dispute", "metadata", "sales_tax_paid?",
        # Calculated
        "stripe_fee", "sales_tax", "revenue", "total_deposit", "refund_fee", "refund_tax", "refund_revenue", "total_refund",
        # Transfer
        "charge_gross", "charge_fees", "refund_gross", "refund_fees", "charge_count", "refund_count", "net"
      ]
      pages = Stripe::Charge.all(count: 1, created: {gte: start_time.to_i, lte: end_time.to_i})
      0.upto((pages.count/100)+1) do |x|
        Stripe::Charge.all(offset: x*100, count: 100, created: {gte: start_time.to_i, lte: end_time.to_i} ).each do |charge|
          next unless charge["paid"]
          charge_amount = (charge["amount"].to_i/100.00)
          stripe_csv << [
            charge["id"], charge["object"], Time.at(charge["created"]), charge["paid"], charge_amount, charge["refunded"], charge["card"]["id"], charge["card"]["object"], charge["card"]["last4"], charge["card"]["type"], charge["card"]["exp_month"], charge["card"]["exp_year"], charge["card"]["fingerprint"], charge["card"]["customer"], charge["card"]["country"], charge["card"]["name"], charge["card"]["address_line1"], charge["card"]["address_line2"], charge["card"]["address_city"], charge["card"]["address_state"], charge["card"]["address_zip"], charge["card"]["address_country"], charge["card"]["cvc_check"], charge["card"]["address_line1_check"], charge["card"]["address_cip_check"], charge["captured"], charge["balance_transaction"], charge["failure_message"], charge["failure_code"], (charge["amount_refunded"].to_i/100.00), (charge["refunds"].first.present? ? Time.at(charge["refunds"].first["created"]) : nil), (charge["refunds"].first.present? ? charge["refunds"].first["balance_transaction"] : nil), charge["customer"], charge["invoice"], charge["description"], charge["dispute"], charge["metadata"], charge["description"].include?("WA state").to_s,
            stripe_fee(charge), sales_tax(charge), revenue(charge), total_deposit(charge), refund_fee(charge), refund_tax(charge), refund_revenue(charge), total_refund(charge) # calculated
          ]
        end
      end

      old_pages = Stripe::Charge.all(count: 1, :refunded => true, created: {gte: start_time.to_i, lte: end_time.to_i})
      0.upto((pages.count/100)+1) do |x|
        Stripe::Charge.all(offset: x*100, count: 100, :refunded => true, created: {gte: (start_time-1.month).beginning_of_month.to_i, lte: start_time.beginning_of_day.to_i} ).each do |charge|
          if charge["refunded"]
            refund_at = Time.at(charge["refunds"].first["created"])
            if refund_at.between?(start_time, end_time)
              charge_amount = (charge["amount"].to_i/100.00)
              stripe_csv << [
                charge["id"], charge["object"], Time.at(charge["created"]), charge["paid"], (charge["amount"].to_i/100.00), charge["refunded"], charge["card"]["id"], charge["card"]["object"], charge["card"]["last4"], charge["card"]["type"], charge["card"]["exp_month"], charge["card"]["exp_year"], charge["card"]["fingerprint"], charge["card"]["customer"], charge["card"]["country"], charge["card"]["name"], charge["card"]["address_line1"], charge["card"]["address_line2"], charge["card"]["address_city"], charge["card"]["address_state"], charge["card"]["address_zip"], charge["card"]["address_country"], charge["card"]["cvc_check"], charge["card"]["address_line1_check"], charge["card"]["address_cip_check"], charge["captured"], charge["balance_transaction"], charge["failure_message"], charge["failure_code"], (charge["amount_refunded"].to_i/100.00), (charge["refunds"].first.present? ? Time.at(charge["refunds"].first["created"]) : nil), (charge["refunds"].first.present? ? charge["refunds"].first["balance_transaction"] : nil), charge["customer"], charge["invoice"], charge["description"], charge["dispute"], charge["metadata"], charge["description"].include?("WA state").to_s,
                stripe_fee(charge), sales_tax(charge), revenue(charge), total_deposit(charge), refund_fee(charge), refund_tax(charge), refund_revenue(charge), total_refund(charge)# Calculated
              ]
            end
          end
        end
      end

      Stripe::Transfer.all(count: 100, date: {gte: start_time.to_i, lte: end_time.to_i}).each do |transfer|
        stripe_csv << [
          transfer["id"], transfer["object"], Time.at(transfer["date"]), nil, (transfer["amount"].to_i/100.00), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
          # calculated
          nil, nil, nil, nil, nil, nil, nil, nil,
          (transfer["summary"]["charge_gross"].to_i/100.00), (transfer["summary"]["charge_fees"].to_i/100.00), (transfer["summary"]["refund_gross"].to_i/100.00), (transfer["summary"]["refund_fees"].to_i/100.00), (transfer["summary"]["charge_count"].to_i), (transfer["summary"]["refund_count"].to_i), (transfer["summary"]["net"].to_i/100.00)
        ]
      end
    end
    return csv_string
  end
end