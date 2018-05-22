rails_root = ENV['RAILS_ROOT'] || File.dirname(__FILE__) + '/../..'
rails_env = ENV['RAILS_ENV'] || 'development'


# This stubs out the Resque module interface, so indivdual tests don't
# need to mock out the Resque.enqueue method each time.
module MockResque
  extend self

  def redis=(server)
  end

  def enqueue(klass, *args)
  end

  module Plugins
    module Lock
    end
  end
end

if rails_env == 'test'
  Resque = MockResque
end

Resque.redis = ENV['REDIS_URL']

# Configure the Coverband Middleware
require 'coverband'
Coverband.configure
