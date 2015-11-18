class StripeEvent < ActiveRecord::Base
  attr_accessible :event_id, :object, :api_version, :request_id, :event_type, :created, :event_at, :livemode, :data
  serialize :data, JSON
end
