namespace :quickbase do
  task :generate_report => :environment do
    started_at = Time.now
    report_name = started_at.strftime("%Y-%m-%d-%H-%M-%S")
    Rails.logger.info "Quickbase:GenerateReport #{report_name} - Starting #{Time.now} on report #{report_name}"
    sqs = Aws::SQS::Client.new(region: 'us-east-1')
    serial_numbers = []
    circulator_addresses_to_gather = []
    Rails.logger.info "Quickbase:GenerateReport #{report_name} - Retrieving records"
    results = QuickbaseClient.getAllValuesForFields(QuickbaseOptions[:units_id], ['Record ID#',"Date Created","serial_number"], nil, QuickbaseOptions[:units_query_id])
    Rails.logger.info "Quickbase:GenerateReport #{report_name} - Got #{results["serial_number"].length} records back"
    count = results["serial_number"].length-1 # Start from 0
    0.upto(count) do |x|
      record_id = results["Record ID#"][x]
      serial_number = results["serial_number"][x]
      created_at = Time.at(results["Date Created"][x].to_f/1000)
      Rails.logger.info "Quickbase:GenerateReport #{report_name} - On #{record_id} (Serial: #{serial_number}) from #{created_at}"
      if serial_number.nil?
        Rails.logger.info "Quickbase:GenerateReport #{report_name} - skipping record #{x}"
        next
      end
      if (started_at - created_at) > 3.days
        circulator_addresses = Circulator.unscoped.where(serial_number:serial_number).pluck(:circulator_id).uniq
        serial_numbers << serial_number
        circulator_addresses_to_gather += circulator_addresses
        Rails.logger.info "Quickbase:GenerateReport #{report_name} - Updating #{record_id} (Serial: #{serial_number}) with \n#{circulator_addresses.join("\n")}"
        QuickbaseClient.addFieldValuePair('records_requested', nil, nil, "1")
        QuickbaseClient.addFieldValuePair('Circulator Addresses', nil, nil, circulator_addresses.join("\n"))
        QuickbaseClient.editRecord(QuickbaseOptions[:units_id], record_id, QuickbaseClient.fvlist)
        Rails.logger.info "Quickbase:GenerateReport #{report_name} - Marked #{record_id} as records_requested"
      end
    end
    start_time = (Time.now-120.days).strftime("%Y-%m-%d")
    end_time = (Time.now-1.days).strftime("%Y-%m-%d")
    circulator_addresses_to_gather.flatten!

    counter = 1
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
