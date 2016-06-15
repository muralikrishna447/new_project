class Api::CirculatorSerializer < ApplicationSerializer
  format_keys :lower_camel
  attributes :circulator_id, :serial_number, :notes, :secret_key, :name, :last_accessed_at

  def secret_key
    # Was stored as binary, now convert back to hex!
    secret_key = object.secret_key
    if secret_key
      return secret_key.unpack('H*')[0]
    else
      return nil
    end
  end
end
