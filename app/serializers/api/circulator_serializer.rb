class Api::CirculatorSerializer < ApplicationSerializer
  format_keys :lower_camel
  attributes :id, :serialNumber, :notes
end
