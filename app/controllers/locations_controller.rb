class LocationsController < ApplicationController

  def autocomplete
    input = params[:input]
    key = google_simple_api_key
    url = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=#{input}&key=#{key}"
    response = HTTParty.get(url)
    render json: response
  end

end