require 'aws-sdk'

class CirculatorAthenaSync
  @queue = :CirculatorAthenaSync

  def self.perform(options = {})
    region = options[:region] || 'us-east-1'
    database = options[:database] || "extracted_logs"
    work_group = options[:work_group] || "primary"
    output_location = options[:output_location] || "s3://aws-athena-query-results-021963864089-us-east-1"
    limit = options[:limit] || 1000
    timeout = options[:timeout] || 30 # seconds

    @client = Aws::Athena::Client.new(
        region: region
    )

    serial_numbers = Circulator.where(:athena_sync_at => nil).limit(limit).pluck(:serial_number)
    quoted_serial_numbers = serial_numbers.map {|s| "'#{s}'"}
    query = "select distinct(serial_number), hardware_version, hardware_options "\
              "from identify_circulator_reply "\
              "where serial_number in (#{quoted_serial_numbers.join(',')}) "\
              "limit #{limit}"
    params = {
        query_string: query,
        query_execution_context: {
            database: database,
        },
        result_configuration: {
            output_location: output_location,
        },
        work_group: work_group,
    }

    Rails.logger.info("CirculatorAthenaSync - serial_numbers.count=#{serial_numbers.count} ")
    Rails.logger.info("CirculatorAthenaSync - start_query_execution params=#{params.inspect}")

    response = @client.start_query_execution(params)
    @query_execution_id = response.query_execution_id

    wait_for_query(timeout)
    process_query_results
  end

  private

  def self.wait_for_query(timeout)
    done_status = Set['SUCCEEDED', 'FAILED', 'CANCELLED']
    done = false
    wait = 0
    while !done
      if wait > timeout
        raise StandardError.new "CirculatorAthenaSync timed out waiting for query_execution_id: #{@query_execution_id}"
      end

      sleep(1)
      wait += 1

      response = @client.get_query_execution({ query_execution_id: @query_execution_id })
      state = response.query_execution.status.state
      done = done_status.include?(state)
    end
  end

  def self.process_query_results
    more_results = true
    next_token = nil
    max_results = 1000

    while more_results
      response = @client.get_query_results({
                                               query_execution_id: @query_execution_id,
                                               next_token: next_token,
                                               max_results: max_results
                                           })
      results = response.result_set.rows
      more_results = response.next_token.present?
      Rails.logger.info("CirculatorAthenaSync - get_query_results - results.count=#{results.count} more_results=#{more_results}")
      update_results(results)
    end
  end


  # results => Array<serial_number, hardware_version, hardware_options>
  def self.update_results(results)
    if results.count > 0
      results.shift
    end

    results.each do |row|
      serial_number = row.data[0].var_char_value
      hardware_version = row.data[1].var_char_value
      hardware_options = row.data[2].var_char_value

      Rails.logger.info("CirculatorAthenaSync - processing result row - serial_number=#{serial_number} hardware_version=#{hardware_version} hardware_options=#{hardware_options}")

      circulator = Circulator.find_by_serial_number!(serial_number)
      circulator.hardware_version = hardware_version
      circulator.hardware_options = hardware_options
      circulator.athena_sync_at = Time.now
      circulator.save!

      if circulator.premium_offer_eligible?
        user = circulator.circulator_users.first
        Rails.logger.info("CirculatorAthenaSync - make_premium_member - user.id=#{user.id}")
        price = 0
        user.make_premium_member(price)
      end
    end
  end

end
