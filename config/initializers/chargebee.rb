ChargeBee.configure(
  site: ENV['CHARGEBEE_SITE'],
  api_key: ENV['CHARGEBEE_API_KEY']
)


# Patching in the checkout_gift method which is not available in the version of Chargebee we are using
# The later version of Chargebee requires json_pure 2.0+ which is not compatible
# with our (very old) version of ActiveRecord's json serialization
ChargeBee::HostedPage.class_eval do
  def self.checkout_gift(params, env=nil, headers={})
    ChargeBee::Request.send('post', uri_path("hosted_pages","checkout_gift"), params, env, headers)
  end
end