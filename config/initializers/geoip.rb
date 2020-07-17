if Rails.env.development? || Rails.env.test?
  Rails.configuration.geoip = OpenStruct.new(
    is_configured: true,
    license: 'v6DjqPqzPsNL',
    user: '106517',
    s3_key: 'ip-geolocation/maxmind_country.mmdb',
    s3_region: 'us-east-1',
  )
elsif ENV["GEOIP_LICENSE"].present? && ENV["GEOIP_USER"].present?
  Rails.configuration.geoip = OpenStruct.new(
    is_configured: true,
    license: ENV["GEOIP_LICENSE"],
    user: ENV["GEOIP_USER"],
    s3_key: 'ip-geolocation/maxmind_country.mmdb',
    s3_region: 'us-east-1',
    )
else
  Rails.configuration.geoip = OpenStruct.new(
    is_configured: false,
    license: nil,
    user: nil,
    s3_key: nil,
    s3_region: 'us-east-1'
    )
end

Rails.configuration.geoip.bucket = {
    development: 'cs-website-resources-development',
    staging: 'cs-website-resources-staging',
    staging2: 'cs-website-resources-staging',
    production: 'cs-website-resources-production'
}[Rails.env.to_sym]

Rails.configuration.geoip.maxmind = "https://download.maxmind.com/app/geoip_download"

unless Rails.env.development? || Rails.env.test?
  # mmdb File download from S3 and store inside tmp folder
  path = "#{Rails.root}/tmp/maxmind"
  FileUtils.mkdir_p(path)
  if MMDBCloud.download("#{path}/maxmind-country.mmdb")
    GEO_IP = MaxMind::DB.new("#{path}/maxmind-country.mmdb")
    FileUtils.rm_rf(path)
  end
end
