ActiveAdmin.register MixpanelData do
  # require 'digest/md5'

  # expire = (DateTime.now + 5.minutes).utc.to_s(:number)
  # api_key = 'ccf6e1e8a37992e4119e42a14557b4a2'
  # api_secret = 'a2f59ee56f798fde108708277bddd4f7'
  
  # parameters = {api_key: api_key, expire: expire}.to_query
  # sig = Digest::MD5.hexdigest(parameters + api_secret)


  # content do
  #   link_to expire, "http://mixpanel.com/api/2.0/engage/?expire=#{expire}&api_key=#{api_key}&sig=#{sig}", target: '_blank'
  # end



  
  # csv = CSV.generate {|csv| data.to_a.each {|elem| csv << elem} }

  # content do
  #   # data
  #   csv
  # end

  controller do
    def index
      require 'csv'
      config = {api_key: 'ccf6e1e8a37992e4119e42a14557b4a2', api_secret: 'a2f59ee56f798fde108708277bddd4f7'}
      client = Mixpanel::Client.new(config)

      data = client.request('engage', {

      })
      csv = CSV.generate {|csv| data.to_a.each {|elem| csv << elem} }
      send_data csv
    end
  end

end