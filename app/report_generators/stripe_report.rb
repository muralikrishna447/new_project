  class StripeReport
  class << self
    def class_sales(class_name, start_date, end_date)
      @transaction_fee = 0.3
      @per_transaction_percent = 0.029
      @sales_tax = 1.095
      raise "Date format Invalid" unless start_date.match(/\d{4}-\d{2}-\d{2}/) && end_date.match(/\d{4}-\d{2}-\d{2}/)
      start_time = Time.parse(start_date).beginning_of_day
      end_time = Time.parse(end_date).end_of_day

      csv_string = CSV.generate do |stripe_csv|
        stripe_csv << [
          "id", "object", "transaction_created", "paid", "amount", "refunded", "card_id", "card_object", "last4", "card_type", "exp_month", "exp_year", "fingerprint", "customer", "country", "name", "address_line1", "address_line2", "address_city", "address_state", "address_zip", "address_country", "cvc_check", "address_line1_check", "address_zip_check", "captured", "balance_transaction", "failure_message", "failure_code", "amount_refunded", "refund_at", "refund_transaction", "customer", "invoice", "description", "dispute", "metadata", "sales_tax_paid?",
          # Calculated
          "stripe_fee", "sales_tax", "revenue", "total_deposit", "refund_fee", "refund_tax", "refund_revenue", "total_refund"
        ]
        gather_charges({paid: true, refunded: false, disputed: false, created: {gte: start_time.to_i, lte: end_time.to_i}}) do |charge|
          next if charge["description"].blank? || !charge["description"].downcase.include?(class_name.downcase)
          puts 'found record!'
          charge_amount = (charge["amount"].to_i/100.00)
          stripe_csv << [
            charge["id"], 'charge', Time.at(charge["created"]), charge["paid"], charge_amount, charge["refunded"], charge["card"]["id"], charge["card"]["object"], charge["card"]["last4"], charge["card"]["type"], charge["card"]["exp_month"], charge["card"]["exp_year"], charge["card"]["fingerprint"], charge["card"]["customer"], charge["card"]["country"], charge["card"]["name"], charge["card"]["address_line1"], charge["card"]["address_line2"], charge["card"]["address_city"], charge["card"]["address_state"], charge["card"]["address_zip"], charge["card"]["address_country"], charge["card"]["cvc_check"], charge["card"]["address_line1_check"], charge["card"]["address_cip_check"], charge["captured"], charge["balance_transaction"], charge["failure_message"], charge["failure_code"], (charge["amount_refunded"].to_i/100.00), (charge["refunds"].first.present? ? Time.at(charge["refunds"].first["created"]) : nil), (charge["refunds"].first.present? ? charge["refunds"].first["balance_transaction"] : nil), charge["customer"], charge["invoice"], charge["description"], charge["dispute"], charge["metadata"], charge["description"].include?("WA state").to_s,
            stripe_fee(charge), sales_tax(charge), revenue(charge), total_deposit(charge), refund_fee(charge), refund_tax(charge), refund_revenue(charge), total_refund(charge) # calculated
          ]
        end
        gather_charges({paid:true, refunded: true, disputed: false, created: {gte: start_time.to_i, lte: end_time.to_i}}) do |charge|
          next if charge["description"].blank? || !charge["description"].downcase.include?(class_name.downcase)
          puts 'found record!'
          charge_amount = (charge["amount"].to_i/100.00)
          stripe_csv << [
            charge["id"], 'refund', Time.at(charge["created"]), charge["paid"], charge_amount, charge["refunded"], charge["card"]["id"], charge["card"]["object"], charge["card"]["last4"], charge["card"]["type"], charge["card"]["exp_month"], charge["card"]["exp_year"], charge["card"]["fingerprint"], charge["card"]["customer"], charge["card"]["country"], charge["card"]["name"], charge["card"]["address_line1"], charge["card"]["address_line2"], charge["card"]["address_city"], charge["card"]["address_state"], charge["card"]["address_zip"], charge["card"]["address_country"], charge["card"]["cvc_check"], charge["card"]["address_line1_check"], charge["card"]["address_cip_check"], charge["captured"], charge["balance_transaction"], charge["failure_message"], charge["failure_code"], (charge["amount_refunded"].to_i/100.00), (charge["refunds"].first.present? ? Time.at(charge["refunds"].first["created"]) : nil), (charge["refunds"].first.present? ? charge["refunds"].first["balance_transaction"] : nil), charge["customer"], charge["invoice"], charge["description"], charge["dispute"], charge["metadata"], charge["description"].include?("WA state").to_s,
            stripe_fee(charge), sales_tax(charge), revenue(charge), total_deposit(charge), refund_fee(charge), refund_tax(charge), refund_revenue(charge), total_refund(charge) # calculated
          ]
        end
        gather_charges({paid: true, refunded: false, disputed: true, created: {gte: start_time.to_i, lte: end_time.to_i}}) do |charge|
          next if charge["description"].blank? || !charge["description"].downcase.include?(class_name.downcase)
          puts 'found record!'
          charge_amount = (charge["amount"].to_i/100.00)
          stripe_csv << [
            charge["id"], 'dispute', Time.at(charge["created"]), charge["paid"], charge_amount, charge["refunded"], charge["card"]["id"], charge["card"]["object"], charge["card"]["last4"], charge["card"]["type"], charge["card"]["exp_month"], charge["card"]["exp_year"], charge["card"]["fingerprint"], charge["card"]["customer"], charge["card"]["country"], charge["card"]["name"], charge["card"]["address_line1"], charge["card"]["address_line2"], charge["card"]["address_city"], charge["card"]["address_state"], charge["card"]["address_zip"], charge["card"]["address_country"], charge["card"]["cvc_check"], charge["card"]["address_line1_check"], charge["card"]["address_cip_check"], charge["captured"], charge["balance_transaction"], charge["failure_message"], charge["failure_code"], (charge["amount_refunded"].to_i/100.00), (charge["refunds"].first.present? ? Time.at(charge["refunds"].first["created"]) : nil), (charge["refunds"].first.present? ? charge["refunds"].first["balance_transaction"] : nil), charge["customer"], charge["invoice"], charge["description"], charge["dispute"], charge["metadata"], charge["description"].include?("WA state").to_s,
            stripe_fee(charge), sales_tax(charge), revenue(charge), total_deposit(charge), refund_fee(charge), refund_tax(charge), refund_revenue(charge), total_refund(charge) # calculated
          ]
        end
      end
      return csv_string
    end

    def quickbooks_report(start_date, end_date)
      raise "Date format Invalid" unless start_date.match(/\d{4}-\d{2}-\d{2}/) && end_date.match(/\d{4}-\d{2}-\d{2}/)
      # start_time = Time.parse("2015-02-01").beginning_of_day
      # end_time = Time.parse("2015-02-28").end_of_day
      start_time = Time.parse(start_date).beginning_of_day
      end_time = Time.parse(end_date).end_of_day
      # Check is for money going out
      # Deposit for money going in
      stripe_lifetime_export()
      header = []
      transfers = []
      charges = []
      refunds = []
      disputes = []
      header << ["!TRNS", "TRNSID", "TRNSTYPE", "DATE", "ACCNT", "NAME", "CLASS","AMOUNT", "MEMO"]
      header << ["!SPL","SPLID","TRNSTYPE","DATE","ACCNT","NAME","CLASS","AMOUNT","MEMO"]
      header << ["!ENDTRNS"]
      CSV.foreach(Rails.root.join('tmp','stripe_export.csv'), headers: true) do |stripe_record|
        # Stripe Charges
        if stripe_record["object"] == "charge"
          if transaction_type(stripe_record) == "CHECK"
            # Parse out the refund
            refund = JSON.parse(stripe_record["latest_refund_created"])

            if stripe_record["latest_refund_created"].present? && Time.at(refund["created"]).between?(start_time, end_time)
              refund_transaction(stripe_record, refund, refunds)
            end

            if Time.parse(stripe_record["created_at"]).between?(start_time, end_time)
              charge_transaction(stripe_record,charges)
            end

          elsif transaction_type(stripe_record) == "DISPUTE"
            # Create the charge if it happened during our start/end time
            if Time.parse(stripe_record["created_at"]).between?(start_time, end_time)
              charge_transaction(stripe_record,disputes)
            end

            # Create the dispute if it happened during our start/end time
            if stripe_record["dispute_description"].present? && Time.parse(stripe_record["dispute_created"]).between?(start_time, end_time)
              dispute_transaction(stripe_record, disputes)
            end

            # Create the won record if it happened during our start and end time
            if stripe_record["won_description"].present? && Time.parse(stripe_record["won_created"]).between?(start_time, end_time)
              won_transaction(stripe_record, disputes)
            end
          elsif transaction_type(stripe_record) == "DEPOSIT"
            if Time.parse(stripe_record["created_at"]).between?(start_time, end_time)
              charge_transaction(stripe_record, charges)
            end
          end
        end
      end
      gather_transfers(date: {gte: start_time.to_i, lte: end_time.to_i}) do |transfer|
        transfer_transaction(transfer, transfers)
      end

      document = header + refunds + charges + disputes + transfers
      # csv_file = CSV.open(Rails.root.join('tmp', 'quickbooks.tsv'), 'wb', col_sep: "\t") do |tsv|
      csv_file = CSV.generate(col_sep: "\t") do |tsv|
        document.each{|d| tsv << d }
      end
      # For short circuiting and just outputting a file to be parsed later locally.
      # a = File.new('tmp/for_ed_quickbook.tsv', 'wb')
      # a.puts csv_file
      # a.close
      csv_file
    end

    private
    def transaction_type(stripe_record)
      if stripe_record["refund_revenue"].to_f > 0
        "CHECK"
      elsif stripe_record["dispute_description"]
        "DISPUTE"
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
      elsif stripe_record["description"].include?("Fluid Gels")
        "Fluid Gels"
      elsif stripe_record["description"].include?("Salmon 104")
        "Salmon 104"
      elsif stripe_record["description"].include?("Barbecue")
        "Barbecue"
      elsif stripe_record["description"].include?("Knife Sharpening")
        "Knife Sharpening"
      elsif stripe_record["description"].include?("Burgers")
        "Burgers"
      elsif stripe_record["description"].include?("Beyond the Basics")
        "SV201"
      elsif stripe_record["description"].include?("Coffee")
        "Coffee"
      elsif stripe_record["description"].include?("Premium")
        "Premium"
      elsif stripe_record["description"].include?("Joule")
        "Joule"
      else
        "Undefined"
      end
    end

    def stripe_fee(charge, stripe_order=nil)
      charge_amount = (charge["amount"].to_i/100.00)
      (charge_amount*@per_transaction_percent+@transaction_fee).round(2)
    end

    def sales_tax(charge, stripe_order=nil)
      if stripe_order
        -1*tax_charged(stripe_order)
      else
        charge_amount = (charge["amount"].to_i/100.00)
        if charge["description"].include?("WA state")
          -1*(charge_amount-(charge_amount/sales_tax_from_date(charge))).round(2)
        else
          0
        end
      end
    end

    def sales_tax_from_date(charge)
      if Time.at(charge["created"]) < Time.parse("2015-04-01").beginning_of_day
        1.095
      else
        1.096
      end
    end

    def revenue(charge, stripe_order=nil)
      charge_amount = (charge["amount"].to_i/100.00)
      -1*(charge_amount + sales_tax(charge, stripe_order))
    end

    def total_deposit(charge, stripe_order=nil)
      -1*(revenue(charge, stripe_order) + sales_tax(charge, stripe_order)) - stripe_fee(charge, stripe_order)
    end

    def refund_fee(charge, stripe_order=nil)
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

    def refund_tax(charge, stripe_order=nil)
      if stripe_order.blank?
        refund_at = (charge["refunds"].first.present? ? Time.at(charge["refunds"].first["created"]) : nil)
        sales_tax_paid = charge["description"].include?("WA state")
        refund_amount = (charge["amount_refunded"].to_i/100.00)
        if refund_at
          if sales_tax_paid
            (refund_amount-(refund_amount/sales_tax_from_date(charge))).round(2)
          else
            0
          end
        else
          0
        end
      else
        refund_at = (charge["refunds"].first.present? ? Time.at(charge["refunds"].first["created"]) : nil)
        charge_amount = (charge["amount"].to_i/100.00)
        refund_amount = (charge["amount_refunded"].to_i/100.00)
        if charge_amount == refund_amount
          tax_charged(stripe_order)
        else
          if item_price(stripe_order) != charge_amount
            tax = (charge_amount/item_price(stripe_order)).round(4)-1
            (refund_amount*tax).round(2)
          else
            0
          end
        end
      end
    end

    def item_price(stripe_order)
      purchased = stripe_order.items.detect{|item| item.type == 'sku'}
      discount = stripe_order.items.detect{|item| item.type == 'discount'}
      if discount
        ((purchased.amount-discount.amount)/100.0).round(2)
      else
        (purchased.amount/100.0).round(2)
      end
    end

    def refund_revenue(charge, stripe_order=nil)
      refund_amount = (charge["amount_refunded"].to_i/100.00)
      refund_amount - refund_tax(charge, stripe_order)
    end

    def total_refund(charge, stripe_order=nil)
      -1*(refund_revenue(charge, stripe_order) + refund_tax(charge, stripe_order)) - refund_fee(charge, stripe_order)
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
          # Disputes
          "dispute_status", "dispute_won_loss", "dispute_disputed_at", "dispute_net", "dispute_amount", "dispute_fee", "dispute_description", "won_at", "won_net", "won_amount", "won_fee", "won_description",
          # Calculated
          "stripe_fee", "sales_tax", "revenue", "total_deposit", "refund_fee", "refund_tax", "refund_revenue", "total_refund",
          # Transfer
          "charge_gross", "charge_fees", "refund_gross", "refund_fees", "charge_count", "refund_count", "net"
        ]
        gather_charges({paid:true, refunded: false, disputed: false, created: {gte: start_time.to_i, lte: end_time.to_i}}) do |charge|
          next if charge["description"].blank?
          next unless charge["paid"]
          charge_amount = (charge["amount"].to_i/100.00)
          stripe_csv << [
            # Base
            charge["id"], charge["object"], Time.at(charge["created"]), charge["paid"], charge_amount, charge["refunded"], charge["card"]["id"], charge["card"]["object"], charge["card"]["last4"], charge["card"]["type"], charge["card"]["exp_month"], charge["card"]["exp_year"], charge["card"]["fingerprint"], charge["card"]["customer"], charge["card"]["country"], charge["card"]["name"], charge["card"]["address_line1"], charge["card"]["address_line2"], charge["card"]["address_city"], charge["card"]["address_state"], charge["card"]["address_zip"], charge["card"]["address_country"], charge["card"]["cvc_check"], charge["card"]["address_line1_check"], charge["card"]["address_cip_check"], charge["captured"], charge["balance_transaction"], charge["failure_message"], charge["failure_code"], (charge["amount_refunded"].to_i/100.00), (charge["refunds"].first.present? ? Time.at(charge["refunds"].first["created"]) : nil), (charge["refunds"].first.present? ? charge["refunds"].first["balance_transaction"] : nil), charge["customer"], charge["invoice"], charge["description"], charge["dispute"], charge["metadata"], charge["description"].include?("WA state").to_s,
            # Disputes
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            # Calculated
            stripe_fee(charge), sales_tax(charge), revenue(charge), total_deposit(charge), refund_fee(charge), refund_tax(charge), refund_revenue(charge), total_refund(charge) # calculated
          ]
        end

        gather_charges({paid:true, refunded: true, disputed: false, created: {gte: start_time.to_i, lte: end_time.to_i}}) do |charge|
          next if charge["description"].blank?
          if charge["refunded"]
            refund_at = Time.at(charge["refunds"].first["created"])
            charged_at = Time.at(charge["created"])
            # If it was refunded or charged at the date add it to the list
            if refund_at.between?(start_time, end_time) || charged_at.between?(start_time, end_time)
              charge_amount = (charge["amount"].to_i/100.00)
              stripe_csv << [
                # Base
                charge["id"], charge["object"], Time.at(charge["created"]), charge["paid"], (charge["amount"].to_i/100.00), charge["refunded"], charge["card"]["id"], charge["card"]["object"], charge["card"]["last4"], charge["card"]["type"], charge["card"]["exp_month"], charge["card"]["exp_year"], charge["card"]["fingerprint"], charge["card"]["customer"], charge["card"]["country"], charge["card"]["name"], charge["card"]["address_line1"], charge["card"]["address_line2"], charge["card"]["address_city"], charge["card"]["address_state"], charge["card"]["address_zip"], charge["card"]["address_country"], charge["card"]["cvc_check"], charge["card"]["address_line1_check"], charge["card"]["address_cip_check"], charge["captured"], charge["balance_transaction"], charge["failure_message"], charge["failure_code"], (charge["amount_refunded"].to_i/100.00), (charge["refunds"].first.present? ? Time.at(charge["refunds"].first["created"]) : nil), (charge["refunds"].first.present? ? charge["refunds"].first["balance_transaction"] : nil), charge["customer"], charge["invoice"], charge["description"], charge["dispute"], charge["metadata"], charge["description"].include?("WA state").to_s,
                # Dispute
                nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
                # Calculated
                stripe_fee(charge), sales_tax(charge), revenue(charge), total_deposit(charge), refund_fee(charge), refund_tax(charge), refund_revenue(charge), total_refund(charge)# Calculated
              ]
            end
          end
        end

        gather_charges({paid:true, refunded: false, disputed: true, created: {gte: (start_time-3.months).to_i, lte: end_time.to_i}}) do |charge|
          next if charge["description"].blank?
          if charge["dispute"]
            dispute_at = Time.at(charge["dispute"]["created"])
            charged_at = Time.at(charge["created"])
            won = charge["dispute"]["balance_transactions"].detect{|c| c["description"].include?('reversal')}
            # If it was refunded or charged at the date add it to the list
            # if dispute_at.between?(start_time, end_time)
            charge_amount = (charge["amount"].to_i/100.00)
            dispute = charge["dispute"]["balance_transactions"].detect{|c| c["description"].include?('withdrawal')}
            won = charge["dispute"]["balance_transactions"].detect{|c| c["description"].include?('reversal')}
            dispute_net = (((won ? won["net"] : 0) + dispute["net"]).to_f/100.00)
            stripe_csv << [
              # Base
              charge["id"], charge["object"], Time.at(charge["created"]), charge["paid"], (charge["amount"].to_i/100.00), charge["refunded"], charge["card"]["id"], charge["card"]["object"], charge["card"]["last4"], charge["card"]["type"], charge["card"]["exp_month"], charge["card"]["exp_year"], charge["card"]["fingerprint"], charge["card"]["customer"], charge["card"]["country"], charge["card"]["name"], charge["card"]["address_line1"], charge["card"]["address_line2"], charge["card"]["address_city"], charge["card"]["address_state"], charge["card"]["address_zip"], charge["card"]["address_country"], charge["card"]["cvc_check"], charge["card"]["address_line1_check"], charge["card"]["address_cip_check"], charge["captured"], charge["balance_transaction"], charge["failure_message"], charge["failure_code"], (charge["amount_refunded"].to_i/100.00), (charge["refunds"].first.present? ? Time.at(charge["refunds"].first["created"]) : nil), (charge["refunds"].first.present? ? charge["refunds"].first["balance_transaction"] : nil), charge["customer"], charge["invoice"], charge["description"], charge["dispute"], charge["metadata"], charge["description"].include?("WA state").to_s,
              # Dispute
              charge["dispute"]["status"], dispute_net, Time.at(dispute["created"]), (dispute["net"].to_i/100.00), (dispute["amount"].to_i/100.00), (dispute["fee"].to_i/100.00), dispute["description"], (won ? Time.at(won["created"]) : nil), (won ? won["net"].to_f/100.00 : nil), (won ? won["amount"].to_f/100.00 : nil), (won ? won["fee"].to_f/100.00 : nil), (won ? won["description"] : nil),
              # Calculated
              stripe_fee(charge), sales_tax(charge), revenue(charge), total_deposit(charge), refund_fee(charge), refund_tax(charge), refund_revenue(charge), total_refund(charge)# Calculated
            ]
            # end
          end
        end

        # NOTE we should paginate transfers the way we do charges since these are user defineable date ranges
        Stripe::Transfer.all(count: 100, date: {gte: start_time.to_i, lte: end_time.to_i}).each do |transfer|
          stripe_csv << [
            # Base
            transfer["id"], transfer["object"], Time.at(transfer["date"]), nil, (transfer["amount"].to_i/100.00), nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            # Dispute
            nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
            # calculated
            nil, nil, nil, nil, nil, nil, nil, nil,
            (transfer["summary"]["charge_gross"].to_i/100.00), (transfer["summary"]["charge_fees"].to_i/100.00), (transfer["summary"]["refund_gross"].to_i/100.00), (transfer["summary"]["refund_fees"].to_i/100.00), (transfer["summary"]["charge_count"].to_i), (transfer["summary"]["refund_count"].to_i), (transfer["summary"]["net"].to_i/100.00)
          ]
        end
      end
      return csv_string
    end

    def stripe_lifetime_export()
      @transaction_fee = 0.3
      @per_transaction_percent = 0.029
      @sales_tax = 1.095

      headers = [
        # From Stripe
        :id, :object, :created, :livemode, :paid, :status, :amount, :currency, :refunded, :source, :captured, :card, :balance_transaction, :failure_message, :failure_code, :amount_refunded, :customer, :invoice, :description, :dispute, :metadata, :statement_descriptor, :fraud_details, :receipt_email, :receipt_number, :authorization_code, :shipping, :destination, :application_fee, :refunds, :statement_description,
        # Convience
        :created_at, :friendly_amount, :friendly_amount_refunded, :number_of_refunds, :fully_refunded, :sales_tax_collected,
        # Calculated
        :sales_tax, :stripe_fee, :revenue, :total_deposit, :refund_fee, :refund_revenue, :total_refund, :refund_tax,
        # Refunds
        :latest_refund_created, :first_refund_created,
        # Dispute
        :dispute_status, :dispute_won_loss, :dispute_created, :dispute_net, :dispute_amount, :dispute_fee, :dispute_description,
        # Won Dispute
        :won_created, :won_net, :won_amount, :won_fee, :won_description
      ]
      csv_file = CSV.open(Rails.root.join('tmp', 'stripe_export.csv'), 'wb', headers: headers) do |csv|
        csv << headers
        # Get all the charges
        gather_charges({paid:true, created: {gte: Time.parse("2013-10-01").beginning_of_month.to_i, lte: Time.now.to_i}}) do |charge|
          next if charge["description"].blank?
          value = {}
          value.merge!(charge.to_hash)
          value[:refunds] = charge["refunds"].map(&:to_hash)
          value[:created_at] = Time.at(charge["created"]) # Turn created into a time object
          value[:friendly_amount] = (charge["amount"].to_f/100.00) # Turn amount into dollars and cents
          value[:number_of_refunds] = charge["refunds"].count # How many refunds we did
          value[:fully_refunded] = ((charge["amount"]-charge["amount_refunded"]) == 0) # If we fully refuned the charge
          if charge["description"].include?("Payment for order")
            new_style_stripe(value, charge)
          else
            old_style_stripe(value, charge)
          end
          # Refunds
          if charge["refunds"].present?
            value[:latest_refund_created] = charge["refunds"].last
            value[:first_refund_created] = charge["refunds"].first
          else
            value.merge!(latest_refund_created: nil, first_refund_created: nil)
          end
          # Dispute
          if charge["dispute"]
            dispute = charge["dispute"]["balance_transactions"].detect{|c| c["description"].include?('withdrawal')}
            won = charge["dispute"]["balance_transactions"].detect{|c| c["description"].include?('reversal')}
            value[:dispute_status] = charge["dispute"]["status"]
            value[:dispute_won_loss] = (((won ? won["net"] : 0) + dispute["net"]).to_f/100.00)
            value[:dispute_created] = Time.at(dispute["created"])
            value[:dispute_net] = (dispute["net"].to_i/100.00)
            value[:dispute_amount] = (dispute["amount"].to_i/100.00)
            value[:dispute_fee] = (dispute["fee"].to_i/100.00)
            value[:dispute_description] = dispute["description"]
            # Won
            if won
              value[:won_created] = Time.at(won["created"])
              value[:won_net] = (won["net"].to_f/100.00)
              value[:won_amount] = (won["amount"].to_f/100.00)
              value[:won_fee] = (won["fee"].to_f/100.00)
              value[:won_description] = won["description"]
            else
              value.merge!(won_created: nil, won_net: nil, won_amount: nil, won_fee: nil, won_description: nil)
            end
          else
            # Blank Dispute fields
            value.merge!(dispute_status: nil, dispute_won_loss: nil, dispute_created: nil, dispute_net: nil, dispute_amount: nil, dispute_fee: nil, dispute_description: nil)
            # Blank Won fields
            value.merge!(won_created: nil, won_net: nil, won_amount: nil, won_fee: nil, won_description: nil)
          end
          csv << value
        end
      end
    end

    def has_tax?(stripe_order)
      tax_item = stripe_order.items.detect{|item| item.type == 'tax'}
      (tax_item.try(:amount) && tax_item.try(:amount) > 0)
    end

    def tax_charged(stripe_order)
      tax_item = stripe_order.items.detect{|item| item.type == 'tax'}
      if has_tax?(stripe_order)
        (tax_item.try(:amount)/100.0)
      else
        0
      end
    end

    def item_purchased(stripe_order)
      purchased = stripe_order.items.detect{|item| item.type == 'sku'}
      purchased.description
    end

    def new_style_stripe(value, charge)
      order_id = charge['description'].match('or_.*')[0]
      stripe_order = Stripe::Order.retrieve(order_id)
      if has_tax?(stripe_order)
        value[:sales_tax_collected] = true
      else
        value[:sales_tax_collected] = false
      end
      value[:description] = new_style_stripe_description(charge, stripe_order)
      value[:sales_tax] = sales_tax(charge, stripe_order) # How much we collected in tax
      value[:stripe_fee] = stripe_fee(charge, stripe_order)
      value[:revenue] = revenue(charge, stripe_order)
      value[:total_deposit] = total_deposit(charge, stripe_order)
      value[:refund_fee] = refund_fee(charge, stripe_order)
      value[:refund_revenue] = refund_revenue(charge, stripe_order)
      value[:total_refund] = total_refund(charge, stripe_order)
      value[:refund_tax] = refund_tax(charge, stripe_order)
    end

    def new_style_stripe_description(charge, stripe_order)
      desc = item_purchased(stripe_order)
      if has_tax?(stripe_order)
        desc += " With WA Sales Tax"
      end
      desc
    end

    def old_style_stripe(value, charge)
      value[:sales_tax_collected] = charge["description"].include?("WA state")
      # Calculated
      value[:sales_tax] = sales_tax(charge) # How much we collected in tax
      value[:stripe_fee] = stripe_fee(charge)
      value[:revenue] = revenue(charge)
      value[:total_deposit] = total_deposit(charge)
      value[:refund_fee] = refund_fee(charge)
      value[:refund_revenue] = refund_revenue(charge)
      value[:total_refund] = total_refund(charge)
      value[:refund_tax] = refund_tax(charge)
    end

    def quickbooks_description(stripe_record)
      deposit = deposit_type(stripe_record)
      if deposit == 'Joule'
        "Income from Operations:Retail Sales:Product Sales:#{deposit}"
      else
        "Income from Operations:Retail Sales:Digital Sales:#{deposit}"
      end
    end

    def quickbooks_return_description(stripe_record)
      deposit = deposit_type(stripe_record)
      if deposit == 'Joule'
        "Income from Operations:Retail Sales:Product Sales:Product Sales Returns"
      else
        "Income from Operations:Retail Sales:Digital Sales:Digital Sales Returns"
      end
    end

    def quickbooks_dispute_description(stripe_record)
      deposit = deposit_type(stripe_record)
      if deposit == 'Joule'
        "Income from Operations:Retail Sales:Product Sales:Product Sales Disputes"
      else
        "Income from Operations:Retail Sales:Digital Sales:Digital Sales Disputes"
      end
    end

    def refund_transaction(stripe_record, refund, refunds)
      refunds << ["TRNS", "1", "CHECK", Time.at(refund["created"]).to_s(:slashes), "Stripe Account", nil, "Admin", stripe_record["total_refund"].to_f.round(2), "Refund of charge #{stripe_record["id"]}"]
      refunds << ["SPL", "2", "CHECK", Time.at(refund["created"]).to_s(:slashes), quickbooks_return_description(stripe_record), "Online Sales", "Admin", stripe_record["refund_revenue"].to_f.round(2), "Refund for charge ID#{' with WA sales tax' if stripe_record["sales_tax_collected"] == "true"}: #{stripe_record["id"]}"]
      line_number = 3
      if stripe_record["sales_tax_collected"] == "true"
        refunds << ["SPL", line_number, "CHECK", Time.at(refund["created"]).to_s(:slashes), "Sales Tax Payable", "WA State Dept of Revenue", "Admin", stripe_record["refund_tax"].to_f.round(2), "Sales Tax for charge ID: #{stripe_record["id"]}"]
        line_number += 1
      end
      refunds << ["SPL", line_number, "CHECK", Time.at(refund["created"]).to_s(:slashes), "Credit Card Transaction Fees", "Stripe (Vendor)", "Admin", stripe_record["refund_fee"].to_f.round(2), "Refund of fees for #{stripe_record["id"]}"]
      refunds << ["ENDTRNS"]
    end

    def charge_transaction(stripe_record, charges)
      charges << ["TRNS", "1", "DEPOSIT", Time.parse(stripe_record["created_at"]).to_s(:slashes), "Stripe Account", nil, "Admin", stripe_record["total_deposit"].to_f.round(2), "Net for charge ID: #{stripe_record["id"]}"]
      charges << ["SPL", "2", "DEPOSIT", Time.parse(stripe_record["created_at"]).to_s(:slashes), quickbooks_description(stripe_record), "Online Sales", "Admin", stripe_record["revenue"].to_f.round(2), "Charge ID#{' with WA sales tax' if stripe_record["sales_tax_collected"] == "true"}: #{stripe_record["id"]}"]
      line_number = 3
      if stripe_record["sales_tax_collected"] == "true"
        charges << ["SPL", line_number, "DEPOSIT", Time.parse(stripe_record["created_at"]).to_s(:slashes), "Sales Tax Payable", "WA State Dept of Revenue", "Admin", stripe_record["sales_tax"].to_f.round(2), "Sales Tax for charge ID: #{stripe_record["id"]}"]
        line_number += 1
      end
      charges << ["SPL", line_number, "DEPOSIT", Time.parse(stripe_record["created_at"]).to_s(:slashes), "Credit Card Transaction Fees", "Stripe (Vendor)", "Admin", stripe_record["stripe_fee"].to_f.round(2), "Fees for charge ID: #{stripe_record["id"]}"]
      charges << ["ENDTRNS"]
    end

    def dispute_transaction(stripe_record, disputes)
      disputes << ["TRNS", "1", "CHECK", Time.parse(stripe_record["dispute_created"]).to_s(:slashes), "Stripe Account", nil, "Admin", (stripe_record["dispute_net"].to_f.round(2)), "Refund/Dispute of charge #{stripe_record["id"]}"]
      disputes << ["SPL", "2", "CHECK", Time.parse(stripe_record["dispute_created"]).to_s(:slashes), quickbooks_dispute_description(stripe_record), "Online Sales", "Admin", (-1*stripe_record["revenue"].to_f.round(2)), "Refund for charge ID#{' with WA sales tax' if stripe_record["sales_tax_collected"] == "true"}: #{stripe_record["id"]}"]
      line_number = 3
      if stripe_record["sales_tax_collected"] == "true"
        disputes << ["SPL", line_number, "CHECK", Time.parse(stripe_record["dispute_created"]).to_s(:slashes), "Sales Tax Payable", "WA State Dept of Revenue", "Admin", (-1*stripe_record["sales_tax"].to_f.round(2)), "Sales Tax for charge ID: #{stripe_record["id"]}"]
        line_number += 1
      end
      disputes << ["SPL", line_number, "CHECK", Time.parse(stripe_record["dispute_created"]).to_s(:slashes), "Losses due to credit card fraud", nil, "Admin", (stripe_record["dispute_fee"].to_f.round(2)), stripe_record["dispute_description"]]
      disputes << ["ENDTRNS"]
    end

    def won_transaction(stripe_record, disputes)
      disputes << ["TRNS", "1", "DEPOSIT", Time.parse(stripe_record["won_created"]).to_s(:slashes), "Stripe Account", nil, "Admin", (stripe_record["won_net"].to_f.round(2)), "Net for charge ID: #{stripe_record["id"]}"]
      disputes << ["SPL", "2", "DEPOSIT", Time.parse(stripe_record["won_created"]).to_s(:slashes), quickbooks_dispute_description(stripe_record), "Online Sales", "Admin", stripe_record["revenue"].to_f.round(2), "Charge ID#{' with WA sales tax' if stripe_record["sales_tax_collected"] == "true"}: #{stripe_record["id"]}"]
      line_number = 3
      if stripe_record["sales_tax_collected"] == "true"
        disputes << ["SPL", line_number, "DEPOSIT", Time.parse(stripe_record["won_created"]).to_s(:slashes), "Sales Tax Payable", "WA State Dept of Revenue", "Admin", stripe_record["sales_tax"].to_f.round(2), "Sales Tax for charge ID: #{stripe_record["id"]}"]
        line_number += 1
      end
      disputes << ["SPL", line_number, "DEPOSIT", Time.parse(stripe_record["won_created"]).to_s(:slashes), "Losses due to credit card fraud", nil, "Admin", stripe_record["won_fee"].to_f.round(2), stripe_record["won_description"]]
      disputes << ["ENDTRNS"]
    end

    def transfer_transaction(transfer_record, transfers)
      if (transfer_record["amount"].to_i/100.00) > 0
        transfers << ["TRNS", "1", "DEPOSIT", Time.at(transfer_record["date"]).to_s(:slashes), "Commerce BK checking 9541", nil, "Admin", (transfer_record["amount"].to_i/100.00).to_f.round(2), "Transfer from Stripe: #{transfer_record["id"]}"]
        transfers << ["SPL", "2", "DEPOSIT", Time.at(transfer_record["date"]).to_s(:slashes), "Stripe Account", nil, "Admin", (-1*(transfer_record["amount"].to_i/100.00).to_f.round(2)), "Transfer from Stripe: #{transfer_record["id"]}"]
        transfers << ["ENDTRNS"]
      else
        transfers << ["TRNS", "1", "DEPOSIT", Time.at(transfer_record["date"]).to_s(:slashes), "Stripe Account", nil, "Admin", (-1*(transfer_record["amount"].to_i/100.00).to_f.round(2)), "Transfer from Stripe: #{transfer_record["id"]}"]
        transfers << ["SPL", "2", "DEPOSIT", Time.at(transfer_record["date"]).to_s(:slashes), "Commerce BK checking 9541", nil, "Admin", (transfer_record["amount"].to_i/100.00).to_f.round(2), "Transfer from Stripe: #{transfer_record["id"]}"]
        transfers << ["ENDTRNS"]
      end
    end

    def gather_charges(options)
      pages = Stripe::Charge.all(options.merge(count: 1))
      0.upto((pages.count/100)+1) do |x|
        puts "on page #{x} of #{(pages.count/100)+1}"
        Stripe::Charge.all(options.merge(offset: x*100, count: 100)).each do |charge|
          yield(charge)
        end
      end
    end

    def gather_transfers(options)
      pages = Stripe::Transfer.all(options.merge(count: 1))
      0.upto((pages.count/100)+1) do |x|
        puts "on page #{x} of #{(pages.count/100)+1}"
        Stripe::Transfer.all(options.merge(offset: x*100, count: 100)).each do |transfer|
          yield(transfer)
        end
      end
    end
  end
end
