require 'aws-sdk'

class CirculatorAthenaSync
  @queue = :CirculatorAthenaSync

  def self.perform(options = {})
    region = options[:region] || 'us-east-1'
    database = options[:database] || "extracted_logs"
    work_group = options[:work_group] || "primary"
    output_location = options[:output_location] || "s3://circulator-athena-sync-query-results"
    limit = options[:limit] || 1000
    max_wait = options[:max_wait] || 60 # seconds

    @client = Aws::Athena::Client.new(
        region: region
    )

    serial_numbers = Circulator.where(:athena_sync_at => nil).limit(limit).pluck(:serial_number)
    query = "select distinct(serial_number), hardware_version, hardware_options "\
              "from identify_circulator_reply "\
              "where serial_number in (#{serial_numbers.join(',')}) "\
              "limit #{limit}"
    params = {
        query_string: query,
        query_execution_context: {
            database: database,
        },
        result_configuration: {
            output_location: output_location,
            encryption_configuration: {
                encryption_option: "SSE_S3"
            },
        },
        work_group: work_group,
    }

    Rails.logger.info("CirculatorAthenaSync - serial_numbers.count=#{serial_numbers.count} ")
    Rails.logger.info("CirculatorAthenaSync - start_query_execution params=#{params.inspect}")

    @query_execution_id = @client.start_query_execution(params)

    wait_for_query(max_wait)
    process_query_results
  end

  private

  def self.wait_for_query(max_wait)
    done_status = Set['SUCCEEDED', 'FAILED', 'CANCELLED']
    done = false
    wait = 0
    while !done
      if wait > max_wait
        raise StandardError "CirculatorAthenaSync timed out waiting for query_execution_id: #{@query_execution_id}"
      end

      sleep(1)
      response = @client.get_query_execution({ query_execution_id: @query_execution_id })
      done = done_status.include?(response.query_execution.status.state)
      wait += 1
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
    results.each do |row|
      serial_number = row.data[0].var_char_value
      hardware_version = row.data[1].var_char_value
      hardware_options = row.data[2].var_char_value

      Rails.logger.info("CirculatorAthenaSync - processing result row - serial_number=#{serial_number} hardware_version=#{hardware_version} hardware_options=#{hardware_options}")

      circulator = Circulator.find_by_serial_number!(serial_number)
      circulator.update_attributes!({
                                        :hardware_version => hardware_version,
                                        :hardware_options => hardware_options,
                                        :athena_sync_at => Time.now
                                    })

      if circulator.premium_offer_eligible?
        user = circulator.circulator_users.first
        Rails.logger.info("CirculatorAthenaSync - make_premium_member - user.id=#{user.id}")
        price = 0
        user.make_premium_member(price)
      end
    end
  end

end
