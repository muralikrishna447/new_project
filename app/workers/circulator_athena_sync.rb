require 'aws-sdk'

class CirculatorAthenaSync
  @queue = :CirculatorAthenaSync

  def self.perform(options = {})
    region = options[:region] || 'us-east-1'
    database = options[:database] || "extracted_logs"
    work_group = options[:work_group] || "primary"
    output_location = options[:output_location] || "todo-newbucket"
    limit = options[:limit] || 1000

    @client = Aws::Athena::Client.new(
        region: region
    )

    serial_numbers = Circulator.where(:athena_sync_at => nil).limit(limit).pluck(:serial_number)

    query = "select distinct(serial_number), hardware_version, hardware_options "\
              "from identify_circulator_reply "\
              "where serial_number in (#{serial_numbers.join(',')}) "\
              "limit #{limit}"


    Rails.logger.info("CirculatorAthenaSync - serial_numbers.count=#{serial_numbers.count} ")
    Rails.logger.info("CirculatorAthenaSync - start_query_execution params=#{params.inspect}")

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
    @query_execution_id = client.start_query_execution(params)

    wait_for_query
    process_query_results
  end

  private

  def self.wait_for_query
    done_status = Set['SUCCEEDED', 'FAILED', 'CANCELLED']
    done = false
    while !done
      sleep(1)
      response = @client.get_query_execution({ query_execution_id: @query_execution_id })
      done = done_status.include?(response.query_execution.status.state)
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
      circulator = Circulator.find_by_serial_number(row.data[0].var_char_value)
      circulator.update_attributes!({
                                        :hardware_version => row.data[1].var_char_value,
                                        :hardware_options => row.data[2].var_char_value,
                                        :athena_sync_at => Time.now
                                    })

      # TODO - and maintain redemption state

      if circulator.premium_offer_eligible?
        user = circulator.circulator_users.first
        Rails.logger.info("CirculatorAthenaSync - make_premium_member - user.id=#{user.id}")
        price = 0
        user.make_premium_member(price)
      end


    end
  end

end
