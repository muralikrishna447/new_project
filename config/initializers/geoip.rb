require 'geoip2'

if Rails.env.development? || Rails.env.test?
  Geoip2.configure do |conf|
    # Mandatory
    conf.license_key = 'v6DjqPqzPsNL'
    conf.user_id = '106517'

    # Optional
    conf.host = 'geoip.maxmind.com' # Or any host that you would like to work with
    conf.base_path = '/geoip/v2.0' # Or any other version of this API
    conf.parallel_requests = 5 # Or any other amount of parallel requests that you would like to use
  end
else
  Geoip2.configure do |conf|
    # Mandatory
    conf.license_key = ENV["GEOIP_LICENSE"]
    conf.user_id = ENV["GEOIP_USER"]

    # Optional
    conf.host = 'geoip.maxmind.com' # Or any host that you would like to work with
    conf.base_path = '/geoip/v2.0' # Or any other version of this API
    conf.parallel_requests = 5 # Or any other amount of parallel requests that you would like to use
  end
end
