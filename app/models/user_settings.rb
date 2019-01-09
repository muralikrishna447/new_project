class UserSettings < ActiveRecord::Base
  belongs_to :user

  validates_inclusion_of :preferred_temperature_unit, :in => %w( c f ), :allow_nil => true

  API_FIELDS = [:locale, :has_viewed_turbo_intro, :preferred_temperature_unit, :truffle_sauce_purchased]

  attr_accessible *API_FIELDS

end
