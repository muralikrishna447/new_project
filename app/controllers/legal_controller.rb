class LegalController < ApplicationController
  before_filter :load_vars

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
  end
end
