class Api::CirculatorSerializer < ApplicationSerializer
  format_keys :lower_camel
  attributes :id, :serial_number, :notes
end
