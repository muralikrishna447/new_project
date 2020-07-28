class Forum
  @queue = :forum
  def self.perform(type, endpoint, user_id)
    case type
    when "initial_user"
      Retriable.retriable tries: 3 do
        Faraday.get do |req|
          req.url "#{endpoint}/users/#{user_id}/initial?apiKey=xchefsteps&ssoId=#{user_id}"
          req.options[:timeout] = 30
          Rails.logger.info "User: #{user_id} Request: #{req}"
        end
      end

    when "update_user"
      Retriable.retriable tries: 3 do
        Faraday.get do |req|
          req.url "#{endpoint}/users/#{user_id}/update?apiKey=xchefsteps&ssoId=#{user_id}"
          req.options[:timeout] = 30
          Rails.logger.info "User: #{user_id} Request: #{req}"
        end
      end

    end
  end
end
