
geoip_config = OpenStruct.new

Rails.configuration.geoip = geoip_config

if Rails.env.development? || Rails.env.test?
  geoip_config.license = 'v6DjqPqzPsNL'
  geoip_config.user = '106517'
  geoip_config.cache_expiry = 7.days
else
  geoip_config.license = ENV["GEOIP_LICENSE"]
  geoip_config.user = ENV["GEOIP_USER"]
  geoip_config.cache_expiry = 7.days
end
