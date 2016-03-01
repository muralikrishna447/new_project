# TODO: figure out how to use is_hosted_env here
if Rails.env.production? || Rails.env.staging? || Rails.env.staging2?
  Rails.configuration.intercom = {
    :app_id => ENV["INTERCOM_APP_ID"],
    :api_key => ENV["INTERCOM_API_KEY"],
    :secret => ENV["INTERCOM_SECRET"]
  }
else
  Rails.configuration.intercom = {
    :app_id => 'pqm08zug',
    :api_key => '109b6b33ead278d24ef1a83d78e1a31457c13e31',
    :secret => 'TXpMDZMi8_y5HVUNzfveHtWTEVFys9iF8tSurskP'
  }
end

# Configuration here does not match online docs since we're stuck using an old
# version of the client because we're not using Ruby 2.2
Intercom.app_id = Rails.configuration.intercom[:app_id]
Intercom.app_api_key = Rails.configuration.intercom[:api_key]
