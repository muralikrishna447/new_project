class Twitter
  def self.status
    response = HTTParty.get('https://api.twitter.com/1/users/show.json?screen_name=chefsteps&include_entities=true')
    c = ActiveSupport::JSON.decode(response.body)
    c = c['status']
  end

  def self.status_embed
  	status_id = self.status['id']
  	response = HTTParty.get("https://api.twitter.com/1/statuses/oembed.json?id=#{status_id}&hide_thread=true&omit_script=true")
  	response['html']
  end
end