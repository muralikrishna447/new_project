if Rails.env.development?
  Shipwire::Client.configure(
    username: 'accounts+developer@chefsteps.com',
    password: '5Yn4H0!PW47!',
    base_uri: 'https://api.shipwire.com/api/v3'
  )
elsif Rails.env.staging?
  Shipwire::Client.configure(
    username: 'accounts+developer@chefsteps.com',
    password: '5Yn4H0!PW47!',
    base_uri: 'https://api.shipwire.com/api/v3'
  )
elsif Rails.env.production?
  Shipwire::Client.configure(
    username: 'accounts+apiuser@chefsteps.com',
    password: 'a69bbac30f7efe0614c2a8a092d406f7',
    base_uri: 'https://api.shipwire.com/api/v3'
  )
end
