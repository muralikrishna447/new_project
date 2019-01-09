class Api::UserSettingsSerializer < ApplicationSerializer

  attributes *UserSettings::API_FIELDS

end
