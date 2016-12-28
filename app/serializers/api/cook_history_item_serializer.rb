class Api::CookHistoryItemSerializer < ApplicationSerializer
  format_keys :lower_camel
  attributes :id, :program_type, :user_content_id, :user_id
  has_one :joule_cook_history_program,
    serializer: Api::JouleCookHistoryProgramSerializer,
    :dependent => :destroy
  
end
