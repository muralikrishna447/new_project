class Api::Admin::CirculatorSerializer < ApplicationSerializer
  format_keys :lower_camel
  attributes :circulator_id, :name, :serial_number, :notes, :last_accessed_at, :created_at, :updated_at, :deleted_at
end
