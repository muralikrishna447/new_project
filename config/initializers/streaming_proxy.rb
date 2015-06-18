require 'rack/streaming_proxy'

Delve::Application.configure do
  config.streaming_proxy.logger             = Rails.logger                          # stdout by default
  config.streaming_proxy.log_verbosity      = Rails.env.production? ? :low : :high  # :low or :high, :low by default
  config.streaming_proxy.num_retries_on_5xx = 5                                     # 0 by default
  config.streaming_proxy.raise_on_5xx       = true                                  # false by default

  # Will be inserted at the end of the middleware stack by default.
  config.middleware.use Rack::StreamingProxy::Proxy do |request|

    # Inside the request block, return the full URI to redirect the request to,
    # or nil/false if the request should continue on down the middleware stack.
    if request.path.start_with?('/gallery')
      "http://localhost:4000/gallery"
    end
  end
end
