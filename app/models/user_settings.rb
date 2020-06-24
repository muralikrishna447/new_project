class UserSettings < ApplicationRecord
  belongs_to :user

  validates_inclusion_of :preferred_temperature_unit, :in => %w( c f ), :allow_nil => true
  validates_length_of :country_iso2, :is => 2, :allow_nil => true
  validates_length_of :locale, :maximum => 10, :allow_nil => true

  # List Alphabetically....
  API_FIELDS = [
    :country_iso2,
    :has_purchased_truffle_sauce,
    :has_viewed_turbo_intro,
    :locale,
    :preferred_temperature_unit,
  ]

end
