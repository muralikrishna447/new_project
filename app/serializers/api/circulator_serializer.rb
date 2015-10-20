class Api::CirculatorSerializer < ApplicationSerializer
  format_keys :lower_camel
  attributes :circulator_id, :serial_number, :notes, :secret_key
end
