class Api::ActivityLikeSerializer < ApplicationSerializer
  format_keys :lower_camel
  attributes :id, :user_id
  # has_one :user, serializer: Api::ProfileSerializer

end
