# GDPR requires that analytics must not be enabled until the user consents
# This helper exposes APIs to
#   1) determine if consent is needed
#   2) set the consent status
# It must be kept in sync with the equivalent version in ChefSteps/FreshSteps

module CookieConsentHelper

  def cookie_consent_value_accept
    'accept'
  end

  def cookie_consent_key
    'analytics_consent'
  end

  # Returns true if user consent is needed before analytics are enabled, else returns false
  def is_consent_needed?
    intl_user? and !is_consent_in_cookie?
  end

  # Sets the consent cookie to a value that indicates that the user consented
  def set_consent_accept
    set_consent_cookie(cookie_consent_value_accept)
  end

  # In Spree, intl_user? is implemented in a separate helper, but that isn't available here
  def intl_user?
    if cookies[:cs_geo].present?
      country = JSON.parse(cookies[:cs_geo])['country']
      return country == 'US' || country == 'CA'
    end

    false
  end

  # private methods

  private
  def set_consent_cookie(value)
    consent_cookie = get_consent_cookie?
    consent_cookie = value
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