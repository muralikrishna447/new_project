require 'csv'

namespace :reports do
  namespace :stripe do
    desc "Generates an avalara report from old style stripe data"
    task :avalara_from_classes => :environment do
      puts "Starting Avalara from Classes"
      start_time = Time.parse(ENV['START_TIME']).beginning_of_day
      puts "start_time = #{start_time}"
      end_time = Time.parse(ENV['END_TIME']).end_of_day
      puts "end_time = #{end_time}"
      csv_data = CSV.generate do |stripe_csv|
        gather_charges(paid:true, refunded:false, disputed:false, created: {gte: start_time.to_i, lte: end_time.to_i}) do |charge|
          next if charge.description && charge.description.include?('Payment for order')
          stripe_csv << [
            1, # Process Code
            charge.id, # Doc Code
            1, # Doc Type
            Time.at(charge.created).to_s(:slashes), # Doc Date
            'ChefSteps', #Company Code
            'Website', # Customer Code
            nil, #EntityUseCode
            1, #LineNo
            nil, #TaxCode
            nil, #TaxDate
            'P0000000', #ItemCode
            charge.description, #Description
            1, #Qty
            (charge.amount/100.0).to_f, #Amount
            nil, #Discount
            nil, #Ref1
            nil, #Ref2
            nil, #ExemptionNo
            nil, #RevAcct
            nil, #DestAddress
            nil, #DestCity
            nil, #DestRegion (required)
            nil, #DestPostalCode (required)
            nil, #DestCountry
            nil, #OrigAddress
            nil, #OrigCity
            'WA', #OrigRegion
            '98101', #OrigPostalCode
            nil, #OrigCountry
            nil, #LocationCode
            nil, #SalesPersonCode
            nil, #PurchaseOrderNo
            nil, #CurrencyCode
            nil, #ExchangeRate
            nil, #ExchangeRateEffDate
            nil, #PaymentDate
            nil, #TaxIncluded
            nil, #DestTaxRegion
            nil, #OrigTaxRegion
            nil, #Taxable
            nil, #TaxType
            tax_from(charge), #TotalTax (required)
            nil, #CountryName
            nil, #CountryCode
            nil, #CountryRate
            nil, #CountryTax
            nil, #StateName
            nil, #StateCode
            nil, #StateRate
            nil, #StateTax
            nil, #CountyName
            nil, #CountyCode
            nil, #CountyRate
            nil, #CountyTax
            nil, #CityName
            nil, #CityCode
            nil, #CityRate
            nil, #CityTax
            nil, #Other1Name
            nil, #Other1Code
            nil, #Other1Rate
            nil, #Other1Tax
            nil, #Other2Name
            nil, #Other2Code
            nil, #Other2Rate
            nil, #Other2Tax
            nil, #Other3Name
            nil, #Other3Code
            nil, #Other3Rate
            nil, #Other3Tax
            nil, #Other4Name
            nil, #Other4Code
            nil, #Other4Rate
            nil, #Other4Tax
            nil, #ReferenceCode
            nil, #BuyersVATNo
            false #IsSellerImporterOfRecord
          ]
          # puts "Charge Id: #{charge.id}\n
          # Doc Date: #{Time.at(charge.created).to_s(:slashes)}\n
          # Charge Description: #{charge.description}\n
          # Tax: #{tax_from(charge)}\n
          # Amount: #{(charge.amount/100.0).to_f}"
        end
      end
      file = File.new('tmp/stripe_data.csv', 'wb')
      file.puts csv_data
      file.close
      ReportMailer.send_report_file('accounts@chefsteps.com', 'avalara_data', 'here is the stripe data', 'stripe_data.csv', csv_data).deliver
    end

    def tax_from(charge)
      if charge.description.present? && charge.description.include?("WA state")
        (charge.amount.to_i/100.0)
      else
        0.0
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
  end
end
