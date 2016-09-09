if Rails.env.development?
  Shipwire::Client.configure(
    username: 'accounts+staging@chefsteps.com',
    password: 'SECRET',
    base_uri: 'https://api.shipwire.com/api/v3'
  )
end
