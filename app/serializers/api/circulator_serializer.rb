class Api::CirculatorSerializer < ApplicationSerializer
  format_keys :lower_camel
  attributes :id, :serialNumber, :notes

  def url #TODO
    circulator_url(object)
  end
end
