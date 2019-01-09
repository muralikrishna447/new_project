class UserSettings < ActiveRecord::Base
  belongs_to :user

  validates_inclusion_of :preferred_temperature_unit, :in => %w( c f ), :allow_nil => true
  validates_length_of :country_iso2, :is => 2, :allow_nil => true
  validates_length_of :locale, :maximum => 6, :allow_nil => true

  API_FIELDS = [
    :locale,
    :has_viewed_turbo_intro,
    :preferred_temperature_unit,
    :truffle_sauce_purchased,
    :country_iso2
  ]

  attr_accessible *API_FIELDS

end
