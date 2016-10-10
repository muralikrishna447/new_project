
# Otherwise it will be set in Heroku
if Rails.env.development? || Rails.env.test?
  ENV["GEOIP_LICENSE"] = 'v6DjqPqzPsNL'
  ENV["GEOIP_USER"] = '106517'
end
