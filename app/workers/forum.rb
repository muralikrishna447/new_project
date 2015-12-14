class Forum
  @queue = :forum
  def self.perform(type, endpoint, user_id)
    case type
    when "update_user"
      url = "#{endpoint}/users/#{user.id}/initial?apiKey=xchefsteps&ssoId=#{user.id}"
      @logger.info "User: #{user.id} Request url: #{url}"
      begin
        response = HTTParty.get url, timeout: 180
        @logger.info "User: #{user.id} Response: #{response.inspect}"
      rescue Timeout::Error
        @logger.info "Timeout while syncing user: #{user.id}"
      end
    end
  end
end
