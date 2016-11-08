# This file should never be included unless this repo is being consumed as a gem

require 'paranoia'
require 'attr_encrypted'
require_relative '../config/initializers/acts_as_sanitized.rb'
require 'hashids'

# Minimal user model since the real one has too many dependencies
class User < ActiveRecord::Base
  has_many :actor_addresses, as: :actor
end

module MiscellaneousPatches
  # attr_accessible was deprecated in rails 4
  def attr_accessible(*args)
  end
end

ActiveRecord::Base.extend(MiscellaneousPatches)

# Cherry picked models
require_relative '../app/models/circulator.rb'
require_relative '../app/models/circulator_user.rb'
require_relative '../app/models/actor_address.rb'
require_relative '../app/models/auth_token.rb'
require_relative '../app/models/circulator.rb'
require_relative '../app/models/circulator_user.rb'
