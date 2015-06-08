namespace :api do
  task :generate_service_token, [:service_name, :key_file] => [:environment] do |t, args|
    unless args[:service_name]
      puts 'Please provide a service name.'
      puts 'rake api:generate_service_token[SERVICE_NAME]'
    end

    puts "Generating Service Token for #{args[:service_name]}"
    if args[:key_file]
      puts "Using key file #{args[:key_file]}"
      key = OpenSSL::PKey::RSA.new(File.read(args[:key_file]), 'cooksmarter')
      puts key
    else
      puts "Using AUTH_SECRET_KEY environment variable"
      key = OpenSSL::PKey::RSA.new ENV["AUTH_SECRET_KEY"], 'cooksmarter'
    end

    issued_at = (Time.now.to_f * 1000).to_i
    claim = {
      iat: issued_at,
      service: args[:service_name],
      user: {
           id: 200,
         }
    }
    jws = JSON::JWT.new(claim.as_json).sign(key.to_s)
    token = jws.to_s
    puts "token: #{token}"
  end
end
