class StripeEvent < ApplicationRecord
  serialize :data, JSON
end
