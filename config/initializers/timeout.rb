# Heroku timeout is 30s
Rack::Timeout.timeout = Rails.env.development? ? 100 : 10
Rack::Timeout.unregister_state_change_observer(:logger)
