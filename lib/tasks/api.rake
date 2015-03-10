namespace :api do

  task :generate_service_token, [:service_name] => [:environment] do |t, args|
    puts args
    if args[:service_name]
      puts "Generating Service Token for #{args[:service_name]}."
      key = OpenSSL::PKey::RSA.new ENV["AUTH_SECRET_KEY"], 'cooksmarter'
      issued_at = (Time.now.to_f * 1000).to_i
      claim = { 
        iat: issued_at,
        service: args[:service_name]
      }
      jws = JSON::JWT.new(claim.as_json).sign(key.to_s)
      jwe = jws.encrypt(key.public_key)
      token = jwe.to_s
      puts "token: #{token}"
    else
      puts 'Please provide a service name.'
      puts 'rake api:generate_service_token[SERVICE_NAME]'
    end
  end

end