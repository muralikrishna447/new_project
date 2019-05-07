if Rails.env.development? || Rails.env.test?
  Rails.configuration.geoip = OpenStruct.new(
    is_configured: true,
    license: 'v6DjqPqzPsNL',
    user: '106517',
    cache_expiry: 10.seconds
  )
elsif ENV["GEOIP_LICENSE"].present? && ENV["GEOIP_USER"].present?
  Rails.configuration.geoip = OpenStruct.new(
    is_configured: true,
    license: ENV["GEOIP_LICENSE"],
    user: ENV["GEOIP_USER"],
    cache_expiry: 7.days
  )
else
  Rails.configuration.geoip = OpenStruct.new(
    is_configured: false,
    license: nil,
    user: nil,
    cache_expiry: 7.days
  )
end
