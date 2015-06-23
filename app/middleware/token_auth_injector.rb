class TokenAuthInjector
  def initialize(app)
    @app = app
  end
  def call(env)
    puts "BLEHBLH"
    puts env.inspect
    session = env['rack.session']

    if session.has_key? 'warden.user.user.key'
      warden_data = session['warden.user.user.key']
      # TODO - validate warden_data
      puts "CURRENT USER #{warden_data[1][0]}"
      Rails.logger.info "CURRENT USER #{warden_data[1][0]}"
      cookie_jar = ActionDispatch::Request.new(env).cookie_jar
      if cookie_jar[:_chefsteps_token]
        puts "HAS TOKEN"
      else
        puts "NO TOKEN, setting"
        cookie_jar[:_chefsteps_token] = {
          value: 'MAGIC TOKEN',
          expires: 1.year.from_now, # copy from token
        }
      end

      # get web actor address
      # check for token cookie
      # check token validty if present
      # refresh as needed
    else
      puts "NNNO warden whatnot"
    end
    @app.call(env)
  end
end
