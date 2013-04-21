class Twitter
  def self.status
    response = HTTParty.get('https://api.twitter.com/1/users/show.json?screen_name=chefsteps&include_entities=true')
    c = ActiveSupport::JSON.decode(response.body)
    c['status']
  end

  def self.status_embed
    unless self.status.nil?
      status_id = self.status['id']
      response = HTTParty.get("https://api.twitter.com/1/statuses/oembed.json?id=#{status_id}&hide_thread=true&omit_script=true&hide_media=true")
      response['html']
    end
  end
end