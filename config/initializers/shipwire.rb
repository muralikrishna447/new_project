if Rails.env.development?
  Shipwire::Client.configure(
    username: 'accounts+developer@chefsteps.com',
    password: '5Yn4H0!PW47!',
    base_uri: 'https://api.beta.shipwire.com/api/v3'
  )
elsif Rails.env.staging?
  Shipwire::Client.configure(
    username: ENV['SHIPWIRE_USERNAME'],
    password: ENV['SHIPWIRE_PASSWORD'],
    base_uri: 'https://api.shipwire.com/api/v3'
  )
elsif Rails.env.production?
  Shipwire::Client.configure(
    username: ENV['SHIPWIRE_USERNAME'],
    password: ENV['SHIPWIRE_PASSWORD'],
    base_uri: 'https://api.shipwire.com/api/v3'
  )
end
