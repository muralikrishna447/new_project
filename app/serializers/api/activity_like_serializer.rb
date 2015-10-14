class Api::ActivityLikeSerializer < ApplicationSerializer
  format_keys :lower_camel

  has_one :user, serializer: Api::ProfileSerializer

end
