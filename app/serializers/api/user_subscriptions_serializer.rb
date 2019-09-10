class Api::UserSubscriptionsSerializer < ApplicationSerializer
  attributes :id, :plan_id, :status, :is_active
end
