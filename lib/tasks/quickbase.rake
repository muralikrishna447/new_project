namespace :quickbase do
  task :generate_report => :environment do
    started_at = Time.now
    Rails.logger.info "Starting #{Time.now}"
    serial_numbers = []
    Rails.logger.info "Retrieving records"
    results = QuickbaseClient.getAllValuesForFields(QuickbaseOptions[:units_id], ['Record ID#',"Date Created","serial_number"], nil, QuickbaseOptions[:units_query_id])
    count = results["serial_number"].length-1 # Start from 0
    Rails.logger.info "Got #{count} records back"
    0.upto(count) do |x|
      record_id = results["Record ID#"][x]
      serial_number = results["serial_number"][x]
      created_at = Time.at(results["Date Created"][x].to_f/1000)
      Rails.logger.info "On #{record_id} (Serial: #{serial_number}) from #{created_at}"
      if serial_number.nil?
        Rails.logger.info "skipping record"
        next
      end
      if (started_at - created_at) > 3.days
        circulator_addresses = Circulator.unscoped.where(serial_number:serial_number).pluck(:circulator_id).uniq.join("\n")
        serial_numbers << serial_number
        Rails.logger.info "Updating #{record_id} (Serial: #{serial_number}) with \n#{circulator_addresses}"
        QuickbaseClient.addFieldValuePair('records_requested', nil, nil, "1")
        QuickbaseClient.addFieldValuePair('Circulator Addresses', nil, nil, circulator_addresses)
        QuickbaseClient.editRecord(QuickbaseOptions[:units_id], record_id, QuickbaseClient.fvlist)
        Rails.logger.info "Marked #{record_id} as records_requested"
      end
    end

    Rails.logger.info "Sent #{serial_numbers.length} records"
    finished_at = Time.now
    run_time = finished_at-started_at
    Rails.logger.info "Ran for #{run_time.to_i} secconds"
  end
end
