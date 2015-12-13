class Forum
  @queue = :forum
  def self.perform(type, endpoint, user_id)
    case type
    when "update_user"
      HTTParty.get "#{endpoint}/users/#{user.id}/initial?apiKey=xchefsteps&ssoId=#{user.id}"
    end
  end
end
