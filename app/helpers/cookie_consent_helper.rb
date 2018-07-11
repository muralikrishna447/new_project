# GDPR requires that analytics must not be enabled until the user consents
# This helper exposes APIs to
#   1) determine if consent is needed
#   2) set the consent status
# It must be kept in sync with the equivalent version in Spree/FreshSteps

require 'set'

module CookieConsentHelper

  # These countries require explicit consent
  # This list is EU + EAA
  # https://en.wikipedia.org/wiki/European_Economic_Area
  # https://en.wikipedia.org/wiki/Member_state_of_the_European_Union
  COUNTRIES_THAT_REQUIRE_CONSENT = Set.new(%w[
    AT BE BG HR CY CZ DK EE FI FR DE GR HU IE IT
    LV LT LU MT NL PL PT RO SK SI ES SE GB IS LI
    GI NO CH
  ])

  def cookie_consent_value_accept
    'accept'
  end

  def cookie_consent_key
    'analytics_consent'
  end

  # Returns true if user consent is needed before analytics are enabled, else returns false
  def is_consent_needed?
    country = get_country
    COUNTRIES_THAT_REQUIRE_CONSENT.include?(country) and !is_consent_in_cookie?
  end

  def get_country
    cookies[:cs_geo].present? && JSON.parse(cookies[:cs_geo])['country']
  end

  # Sets the consent cookie to a value that indicates that the user consented
  def set_consent_accept
    set_consent_cookie(cookie_consent_value_accept)
  end


  # private methods

  private
  def set_consent_cookie(value)
    # The cookie needs to be set client side, so this function is NOT called when the user clicks the OK button.
    # See cookie_consent_banner.html.erb for the code that is called when user clicks the OK button
    cookies.permanent[:analytics_consent] = {
        :value => value,
        :domain => :all
    }
  end

  private
  def is_consent_in_cookie?
    consent_cookie = get_consent_cookie?
    consent_cookie.present? && consent_cookie == cookie_consent_value_accept
  end

  private
  def get_consent_cookie?
    cookies[:analytics_consent]
  end


end