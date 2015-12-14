class Forum
  @queue = :forum
  def self.perform(type, endpoint, user_id)
    case type
    when "update_user"
      url = "#{endpoint}/users/#{user.id}/initial?apiKey=xchefsteps&ssoId=#{user.id}"
      @logger.info "User: #{user.id} Request url: #{url}"
      response = HTTParty.get url, timeout: 30
      
      if /^2/.match(response.code.to_s)
        @logger.info "Bloom successfully synced user: #{user.id} Response: #{response.inspect}"
      else
        @logger.info "Bloom failed to sync user: #{user.id} Response: #{response.inspect}"
        raise "Bloom failed to sync user: #{user.id}"
      end
    end
  end
end
