Rack::Timeout.timeout = 25 #Set to 5 seconds less than heroku timeout
Rack::Timeout.unregister_state_change_observer(:logger)
