class Forum
  @queue = :forum
  def self.perform(type, endpoint, user_id)
    case type
    when "update_user"
      Faraday.get do |req|
        req.url "#{endpoint}/users/#{user.id}/initial?apiKey=xchefsteps&ssoId=#{user.id}"
        req.options[:timeout] = 3
        req.options[:open_timeout] = 2
      end
    end
  end
end
