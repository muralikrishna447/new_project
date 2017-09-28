namespace :quickbase do
  require 'quickbase_client'

  desc "
  This task will send a message into the joule log processor with all the serial numbers that exchanges have been
  initiated on.
  https://github.com/ChefSteps/joule-log-processor#returns-investigation
  There is a 3 day delay on records to allow the return to be processed and sent before pulling the records"
  task :generate_report => :environment do
    if ENV["QUICKBASE_USERNAME"].present? && ENV["QUICKBASE_PASSWORD"].present?

      QuickbaseClient = QuickBase::Client.init(
        {
          "username" => (ENV["QUICKBASE_USERNAME"]),
          "password" => (ENV["QUICKBASE_PASSWORD"]),
          "appname" => (Rails.env.production? ? "ChefSteps" : "ChefSteps Staging"),
          "org" => "chefsteps-8265"
        }
      )

      if Rails.env.production?
        QuickbaseOptions = {
          units_id: "bmg4hpb6i",
          units_query_id: "10",
          returns_id: "bmg4hpbp7",
          returns_query_id: "26"
        }
      else
        QuickbaseOptions = {
          units_id: "bmrihe3d8",
          units_query_id: "10",
          returns_id: "bm4vtkcqs",
          returns_query_id: "26"
        }
      end
    else
      raise "ERROR - QUICKBASE_USERNAME and QUICKBASE_PASSWORD are missing"
    end
    started_at = Time.now
    report_name = started_at.strftime("%Y-%m-%d-%H-%M-%S")
    Rails.logger.info "Quickbase:GenerateReport #{report_name} - Starting #{Time.now} on report #{report_name}"
    sqs = Aws::SQS::Client.new(region: 'us-east-1')
    serial_numbers = []
    circulator_addresses_to_gather = []
    Rails.logger.info "Quickbase:GenerateReport #{report_name} - Retrieving records"
    results = QuickbaseClient.getAllValuesForFields(QuickbaseOptions[:returns_id], ['Record ID#',"Date Created","Serial Number"], nil, QuickbaseOptions[:returns_query_id])

    # results are weird
    # {
    #   "Record ID#" : [1, 2, 3],
    #   "serial_number" : [167123, 167883, 17010001],
    #   "Date Created" : [...] # MS
    # }
    # So you have to loop through and pull the element from the array out of each of the fields.

    Rails.logger.info "Quickbase:GenerateReport #{report_name} - Got #{results["Serial Number"].length} records back"
    count = results["Serial Number"].length-1 # Start from 0
    0.upto(count) do |x|
      record_id = results["Record ID#"][x]
      serial_number = results["Serial Number"][x]
      created_at = Time.at(results["Date Created"][x].to_f/1000) # Convert time from miliseconds to seconds
      Rails.logger.info "Quickbase:GenerateReport #{report_name} - On #{record_id} (Serial: #{serial_number}) from #{created_at}"
      if serial_number.nil?
        Rails.logger.info "Quickbase:GenerateReport #{report_name} - skipping record #{x}"
        next
      end
      if (started_at - created_at) > 3.days # There is a 3 day delay on records to allow the return to be processed and sent before pulling the records
        circulator_addresses = Circulator.unscoped.where(serial_number:serial_number).pluck(:circulator_id).uniq # Find all circulator addresses
        serial_numbers << serial_number
        circulator_addresses_to_gather += circulator_addresses
        Rails.logger.info "Quickbase:GenerateReport #{report_name} - Updating #{record_id} (Serial: #{serial_number}) with \n#{circulator_addresses.join("\n")}"
        QuickbaseClient.addFieldValuePair('records_requested', nil, nil, "1") # Send that we have requested logs for this unit
        QuickbaseClient.addFieldValuePair('Circulator Addresses', nil, nil, circulator_addresses.join("\n")) # Send all circulator addresses up for the unit
        QuickbaseClient.editRecord(QuickbaseOptions[:returns_id], record_id, QuickbaseClient.fvlist)
        Rails.logger.info "Quickbase:GenerateReport #{report_name} - Marked #{record_id} as records_requested"
      end
    end

    # Get 120 days worth of logs
    start_time = (Time.now-120.days).strftime("%Y-%m-%d")
    end_time = (Time.now-1.days).strftime("%Y-%m-%d")

    # Collect all the circulator addresses
    circulator_addresses_to_gather.flatten!

    counter = 1 # Counter to list off the 512 blocks of circulator address
    circulator_addresses_to_gather.in_groups_of(512, false) do |circ_add|
      body = {
        "jobName" => "#{report_name}_#{counter}",
        "dateRange" => {
          "start" => start_time,
          "end" => end_time
        },
        "queryTerms" => circ_add
      }
      Rails.logger.info "Quickbase:GenerateReport #{report_name} - Sending \n" + body.to_json
      resp = sqs.send_message({
        queue_url: "https://sqs.us-east-1.amazonaws.com/021963864089/joule-log-grep-requests-production", # required
        message_body: body.to_json, # required
      })

      Rails.logger.info "Quickbase:GenerateReport #{report_name} - Got response #{resp.inspect}"
      counter+=1
    end
    Rails.logger.info "Quickbase:GenerateReport #{report_name} - Sent #{serial_numbers.length} records"
    finished_at = Time.now
    run_time = finished_at-started_at
    Rails.logger.info "Quickbase:GenerateReport #{report_name} - Ran for #{run_time.to_i} secconds"
  end
end
