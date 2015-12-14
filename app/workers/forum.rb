class Forum
  @queue = :forum
  def self.perform(type, endpoint, user_id)
    case type
    when "update_user"

      Faraday.get do |req|
        req.url "#{endpoint}/users/#{user_id}/initial?apiKey=xchefsteps&ssoId=#{user_id}"
        req.options[:timeout] = 30
        Rails.logger.info "User: #{user_id} Request: #{req}"
      end

    end
  end
end
