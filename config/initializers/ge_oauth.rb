require 'oauth2'
module GE
    if Rails.env.development? || Rails.env.test?
        id = '2cdcf2e9f51adeeff66ea2a06741f6c589a863d7'
        secret = '3d41bdd8d362b85ed2e5e4cacf92cb416972b6aada44d43ec726cc0694177cba'
    else
        id = ENV["GE_ID"]
        secret = ENV["GE_SECRET"]
    end

    Client = OAuth2::Client.new(id, secret,
            :site => 'https://accounts.brillion.geappliances.com', authorize_url: '/oauth2/auth', token_url: "/oauth2/token")

    RedirectURL =  case Rails.env
    when "development"
        # Use ngrok to support localhost development
        "https://gecsdanbeta.ngrok.io/api/v0/authenticate_ge"
    when "test"
        ""
    when "staging"
        "https://www.chocolateyshatner.com/api/v0/authenticate_ge"
    when "staging2"
        "https://www.vanillanimoy.com/api/v0/authenticate_ge"
    when "production"
        "https://www.chefsteps.com/api/v0/authenticate_ge"
    end

end