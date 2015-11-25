# Gibbon uses HTTParty which allows configuring configuring a proxy in this manner

url = ENV['PROXIMO_URL'] || 'http://proxy:1cd174a4d3b0-4f78-addb-75c98f234c21@proxy-23-21-132-4.proximo.io'
Rails.logger.info("Initializing Gibbon with proximo url [#{url}]")
proximo_uri = URI.parse(url)

Gibbon::APICategory.class_eval do
  default_options[:http_proxyaddr] = proximo_uri.host
  default_options[:http_proxyport] = 80
  default_options[:http_proxyuser] = proximo_uri.user
  default_options[:http_proxypass] = proximo_uri.password
end
