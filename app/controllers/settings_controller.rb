class SettingsController < ApplicationController

  def index
    @settings = Setting.first
    render json: @settings.to_json
  end
end