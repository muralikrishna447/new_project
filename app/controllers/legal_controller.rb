class LegalController < ApplicationController
  before_filter :load_vars

  # Cookie Policy: Specific by language only
  # Warranty: Specific by country + language combination
  # Privacy Policy: Specific by country + language combination
  # EULA: Specific by country + language combination
  # Terms: Terms specific by language only.  Addendums specific by country + language combination

  # Filename Belgium Example:
  # Terms_Dutch
  # Terms_French
  # Terms_Addendum_BE_Dutch
  # Terms_Addendum_BE_French
  # EULA_iOS_Dutch
  # EULA_Android_Dutch
  # EULA_iOS_French
  # EULA_Android_French
  # EULA_iOS_Addendum_BE_Dutch
  # EULA_Android_Addendum_BE_Dutch
  # EULA_iOS_Addendum_BE_French
  # EULA_Android_Addendum_BE_French
  # Privacy_Dutch
  # Privacy_French
  # Warranty_Dutch
  # Warranty_French
  # Cookie_Dutch
  # Cookie_French
  # Cookie_Banner_Dutch
  # Cookie_Banner_French

  def terms
    @terms_template = "legal/terms/#{@selected_language.downcase}"
    @addendums_template = "legal/terms/addendums/#{@country[:code].downcase}_#{@selected_language.downcase}"
  end

  def warranty
    @warranty_template = "legal/terms/addendums/#{@country[:code].downcase}_#{@selected_language.downcase}"
  end

  def privacy_policy
    @privacy_policy_template = "legal/privacy_policy/#{@selected_language.downcase}"
  end

  def cookie_policy
    @cookie_policy_template = "legal/privacy_policy/#{@selected_language.downcase}"
  end

  def eula_android
    @eula_template = "legal/eula_android/#{@selected_language.downcase}"
    @addendums_template = "legal/eula_android/addendums/#{@country[:code].downcase}_#{@selected_language.downcase}"
  end

  def eula_ios
    @eula_template = "legal/eula_ios/#{@selected_language.downcase}"
    @addendums_template = "legal/eula_ios/addendums/#{@country[:code].downcase}_#{@selected_language.downcase}"
  end

  private
  def load_vars
    @eula_terms_url = terms_url
    @eula_privacy_url = privacy_url
    @location = JSON.parse(cookies['cs_geo'])
    puts "LOCATION HERE: #{@location}"
    @countries = [
      {
        code: "US",
        name: "United States",
        languages: ["English"]
      },
      {
        code: "CA",
        name: "Canada",
        languages: ["English", "French"]
      },
      {
        code: "BE",
        name: "Belgium",
        languages: ["Dutch", "French", "German"]
      },
      {
        code: "DK",
        name: "Denmark",
        languages: ["Danish"]
      },
      {
        code: "FI",
        name: "Finland",
        languages: ["Finnish", "Swedish"]
      },
      {
        code: "FR",
        name: "France",
        languages: ["French"]
      },
      {
        code: "DE",
        name: "Germany",
        languages: ["German"]
      },
      {
        code: "IE",
        name: "Ireland",
        languages: ["English"]
      },
      {
        code: "IT",
        name: "Italy",
        languages: ["Italian"]
      },
      {
        code: "NL",
        name: "Netherlands",
        languages: ["Dutch"]
      },
      {
        code: "NO",
        name: "Norway",
        languages: ["Norwegian"]
      },
      {
        code: "ES",
        name: "Spain",
        languages: ["Spanish"]
      },
      {
        code: "SE",
        name: "Sweden",
        languages: ["Swedish"]
      },
      {
        code: "CH",
        name: "Switzerland",
        languages: ["German", "French", "Italian"]
      },
      {
        code: "GB",
        name: "United Kingdom",
        languages: ["English"]
      }
    ]
    @country = @countries.find { |c| c[:code] == @location['country'] }
    @language = params[:language]
    @languages = @country[:languages].map { |e| [e]  }
    @selected_language = @language ? @language : @languages[0][0]
  end
end
