class Forum
  @queue = :forum
  def self.perform(type, endpoint, user_id)
    case type
    when "update_user"
      url = "#{endpoint}/users/#{user.id}/initial?apiKey=xchefsteps&ssoId=#{user.id}"
      response = HTTParty.get url
      @logger.info "User: #{user.id} Response: #{response.inspect}"
    end
  end
end
