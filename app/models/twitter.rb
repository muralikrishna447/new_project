class Twitter
  def self.status
    response = HTTParty.get('https://api.twitter.com/1/users/show.json?screen_name=chefsteps&include_entities=true')
    c = ActiveSupport::JSON.decode(response.body)
    c = c['status']
  end
end