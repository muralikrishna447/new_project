require 'avatax'

if Rails.env.development? || Rails.env.test?
  AvaTax.configure do
    account_number '2000001930'
    license_key '187821B029B8D616'
    service_url 'https://development.avalara.net'
  end
else
  AvaTax.configure do
    account_number ENV['AVATAX_ACCOUNT_NUMBER']
    license_key ENV['AVATAX_LICENSE_KEY']
    service_url ENV['AVATAX_SERVICE_URL']
  end
end
