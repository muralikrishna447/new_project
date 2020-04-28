class StripeEvent < ActiveRecord::Base
  serialize :data, JSON
end
